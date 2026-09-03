#!/usr/bin/env python3
# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""Show, validate, and edit top_earlgrey's clock tree (clocks.srcs /
clocks.derived_srcs in hw/top_earlgrey/data/top_earlgrey.hjson).

This is a *surgical* line-based editor, not a full hjson parse+dump — the
hjson file carries extensive hand-written documentation comments throughout
that a parse/re-serialize round trip would destroy. Every entry in srcs/
derived_srcs is written on one line in the stock file; this tool relies on
that and edits only the specific field on the specific line, byte-for-byte
everywhere else.

Usage:
  util/nebula/clocks.py show
  util/nebula/clocks.py check                      # exit 1 on any hard violation
  util/nebula/clocks.py set main --freq 120000000
  util/nebula/clocks.py set exp_div2 --div 4        # derived clock: div and/or freq
  util/nebula/clocks.py set exp_div2 --freq 18000000 --div 4

After a successful `set`, re-run topgen (see util/nebula/run_topgen.sh) to
regenerate clkmgr/rstmgr/etc. from the new values.
"""
import argparse
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_HJSON = REPO_ROOT / "hw/top_earlgrey/data/top_earlgrey.hjson"

# aon is deliberately load-bearing and excluded from clkmgr entirely:
# rstmgr's POR root, pwrmgr's hand-written (non-templated) low-power FSM,
# and several wake-detect peripherals all assume it. topgen itself cannot
# derive a clock *from* aon (util/topgen/clocks.py throws KeyError), and
# this project's own scope notes deliberately chose not to touch it.
LOCKED_MASTERS = {"aon"}

# USB full-speed PHY timing is conventionally locked to 48MHz. Nothing in
# this RTL/toolchain enforces that (it's a synthesis-only benchmark), so
# this is a warning, not a hard block.
CONVENTIONAL_FREQS = {"usb": 48_000_000}

SRC_RE = re.compile(
    r'\{\s*name:\s*"(?P<name>\w+)"\s*,\s*aon:\s*"(?P<aon>yes|no)"\s*,'
    r'\s*freq:\s*"(?P<freq>\d+)"'
    r'(?P<tail>[^}]*)\}'
)
DERIVED_RE = re.compile(
    r'\{\s*name:\s*"(?P<name>\w+)"\s*,\s*aon:\s*"(?P<aon>yes|no)"\s*,'
    r'\s*div:\s*(?P<div>\d+)\s*,\s*src:\s*"(?P<src>\w+)"\s*,'
    r'\s*freq:\s*"(?P<freq>\d+)"\s*\}'
)


def find_block(text, key):
    """Return (start, end) char offsets of the `key: [ ... ]` block body."""
    m = re.search(rf'{key}:\s*\[', text)
    if not m:
        raise SystemExit(f"could not find '{key}: [' in hjson")
    start = m.end()
    depth = 1
    i = start
    while depth > 0:
        if text[i] == '[':
            depth += 1
        elif text[i] == ']':
            depth -= 1
        i += 1
    return start, i - 1


class ClockConfig:
    def __init__(self, hjson_path):
        self.path = Path(hjson_path)
        self.text = self.path.read_text()
        s0, s1 = find_block(self.text, "srcs")
        d0, d1 = find_block(self.text, "derived_srcs")
        self.srcs = {}
        for m in SRC_RE.finditer(self.text[s0:s1]):
            self.srcs[m.group("name")] = {
                "aon": m.group("aon") == "yes",
                "freq": int(m.group("freq")),
                "span": (s0 + m.start(), s0 + m.end()),
                "match": m,
            }
        self.derived = {}
        for m in DERIVED_RE.finditer(self.text[d0:d1]):
            self.derived[m.group("name")] = {
                "aon": m.group("aon") == "yes",
                "div": int(m.group("div")),
                "src": m.group("src"),
                "freq": int(m.group("freq")),
                "span": (d0 + m.start(), d0 + m.end()),
                "match": m,
            }
        if "aon" not in self.srcs:
            raise SystemExit("no 'aon' clock source found — unexpected hjson shape")
        self.aon_freq = self.srcs["aon"]["freq"]

    def all_names(self):
        return set(self.srcs) | set(self.derived)

    def checks(self):
        """Yield (severity, name, message) for every check, pass or fail.
        severity is one of 'hard', 'soft', 'ok'."""
        for name, c in self.derived.items():
            if c["div"] % 2 != 0:
                yield ("hard", name,
                       f"div={c['div']} is odd — prim_generic_clock_div.sv's "
                       f"ASSERT_INIT(DivEven_A) requires an even divisor; "
                       f"Verilator elaboration will fail")
            else:
                yield ("ok", name, f"div={c['div']} is even")

            src = self.srcs.get(c["src"]) or self.derived.get(c["src"])
            if src is None:
                yield ("hard", name, f"src '{c['src']}' does not exist")
                continue
            expected = src["freq"] // c["div"]
            if src["freq"] % c["div"] != 0 or expected != c["freq"]:
                yield ("hard", name,
                       f"freq={c['freq']} does not equal src '{c['src']}' "
                       f"freq({src['freq']}) / div({c['div']}) = "
                       f"{src['freq'] / c['div']:.3f} — the declared freq is "
                       f"a label topgen trusts verbatim, not something it "
                       f"derives; a mismatch silently mislabels the clock "
                       f"everywhere downstream (docs, regs, any future SDC)")
            else:
                yield ("ok", name, f"freq={c['freq']} matches "
                       f"{c['src']}({src['freq']})/{c['div']}")

            if c["src"] == "aon":
                yield ("hard", name,
                       "src is 'aon' — topgen's clock derivation "
                       "(util/topgen/clocks.py) throws KeyError for any "
                       "derived clock sourced from an aon-marked master; "
                       "this cannot work")

        for name, c in self.srcs.items():
            if name == "aon":
                continue
            if c["freq"] % self.aon_freq != 0:
                yield ("hard", name,
                       f"freq={c['freq']} is not an integer multiple of "
                       f"aon's freq({self.aon_freq}) — clkmgr's frequency-"
                       f"measurement threshold generation "
                       f"(clkmgr.hjson.tpl: 'ratio = int(freq / aon_freq)') "
                       f"silently truncates instead of erroring, producing "
                       f"a miscalibrated glitch-detection window")
            else:
                yield ("ok", name,
                       f"freq={c['freq']} is a multiple of aon "
                       f"({c['freq'] // self.aon_freq}x) — measurement "
                       f"thresholds will compute exactly")

            if name in CONVENTIONAL_FREQS and c["freq"] != CONVENTIONAL_FREQS[name]:
                yield ("soft", name,
                       f"freq={c['freq']} differs from the conventional "
                       f"{CONVENTIONAL_FREQS[name]} Hz USB full-speed PHY "
                       f"rate — fine for this synthesis-only benchmark, but "
                       f"not representative of real USB timing")

    def set_freq(self, name, new_freq, new_div=None, force_aon=False):
        if name in LOCKED_MASTERS and not force_aon:
            raise SystemExit(
                f"refusing to change '{name}': it's structurally load-"
                f"bearing (rstmgr POR root, pwrmgr's hand-written low-power "
                f"FSM, wake-detect peripherals — see project scope notes). "
                f"Pass --force-aon if you really mean this.")
        if name in self.srcs:
            if new_div is not None:
                raise SystemExit(f"'{name}' is a master clock source — it "
                                  f"has no divisor to set")
            c = self.srcs[name]
            new_text = (self.text[:c["span"][0]] +
                        re.sub(r'freq:\s*"\d+"', f'freq: "{new_freq}"',
                               self.text[c["span"][0]:c["span"][1]]) +
                        self.text[c["span"][1]:])
        elif name in self.derived:
            c = self.derived[name]
            div = new_div if new_div is not None else c["div"]
            chunk = self.text[c["span"][0]:c["span"][1]]
            chunk = re.sub(r'div:\s*\d+', f'div: {div}', chunk)
            chunk = re.sub(r'freq:\s*"\d+"', f'freq: "{new_freq}"', chunk)
            new_text = self.text[:c["span"][0]] + chunk + self.text[c["span"][1]:]
        else:
            raise SystemExit(f"no clock named '{name}' (known: "
                              f"{', '.join(sorted(self.all_names()))})")
        self.text = new_text
        self.path.write_text(self.text)


def cmd_show(cfg):
    print(f"{'name':<14}{'type':<10}{'freq (Hz)':<14}{'div':<6}{'src':<8}")
    for name, c in sorted(cfg.srcs.items()):
        print(f"{name:<14}{'master':<10}{c['freq']:<14}{'-':<6}{'-':<8}")
    for name, c in sorted(cfg.derived.items()):
        print(f"{name:<14}{'derived':<10}{c['freq']:<14}{c['div']:<6}{c['src']:<8}")


def cmd_check(cfg):
    n_hard = n_soft = 0
    for sev, name, msg in cfg.checks():
        if sev == "hard":
            n_hard += 1
            print(f"FAIL  {name:<14}{msg}")
        elif sev == "soft":
            n_soft += 1
            print(f"WARN  {name:<14}{msg}")
    if n_hard == 0 and n_soft == 0:
        print("all checks pass")
    else:
        print(f"\n{n_hard} hard failure(s), {n_soft} warning(s)")
    return 1 if n_hard else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--hjson", default=str(DEFAULT_HJSON))
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("show")
    sub.add_parser("check")
    p_set = sub.add_parser("set")
    p_set.add_argument("name")
    p_set.add_argument("--freq", type=int)
    p_set.add_argument("--div", type=int)
    p_set.add_argument("--force-aon", action="store_true")
    p_set.add_argument("--force", action="store_true",
                        help="write even if the result fails a hard check")
    args = ap.parse_args()

    cfg = ClockConfig(args.hjson)

    if args.cmd == "show":
        cmd_show(cfg)
        return 0
    if args.cmd == "check":
        return cmd_check(cfg)
    if args.cmd == "set":
        if args.freq is None and args.div is None:
            raise SystemExit("set requires --freq and/or --div")
        cur = cfg.srcs.get(args.name) or cfg.derived.get(args.name)
        if cur is None:
            raise SystemExit(f"no clock named '{args.name}'")
        new_freq = args.freq if args.freq is not None else cur["freq"]
        cfg.set_freq(args.name, new_freq, args.div, force_aon=args.force_aon)
        print(f"updated '{args.name}' in {cfg.path}")
        cfg2 = ClockConfig(args.hjson)
        rc = cmd_check(cfg2)
        if rc and not args.force:
            raise SystemExit(
                "\nthe new value fails a hard check (see above) — the file "
                "was written anyway (you may want to fix it or re-run "
                "'set' with corrected values). Re-run topgen only once "
                "'check' passes clean.")
        print("\nnext: re-run util/nebula/run_topgen.sh to regenerate "
              "clkmgr/rstmgr/etc. from the new values")
        return rc
    return 0


if __name__ == "__main__":
    sys.exit(main())
