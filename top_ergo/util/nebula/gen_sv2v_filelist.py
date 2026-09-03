#!/usr/bin/env python3
# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""Turn fusesoc's own dependency-resolved file manifest (eda.yml, written by
`fusesoc run --target=syn --setup`) into a file list + include-dir list
sv2v can consume directly.

Why not just `find . -name '*.sv'`: fusesoc's resolution is the actual
source of truth for "what top_earlgrey's syn target needs" — order,
per-core file_type, and include-file flags all come from it. Re-deriving
this by hand (as an earlier ad hoc pass in this project did) drifts the
moment any .core file changes.

A small, documented exclude list remains: a couple of files fusesoc pulls
in as dependencies of DV/FPGA-only cores that are not part of top_earlgrey's
actual synthesizable hierarchy, and which use constructs sv2v/Yosys's
frontend can't parse (drive-strength continuous assigns). See EXCLUDES
below for exactly which and why.

Usage:
  util/nebula/gen_sv2v_filelist.py \
      --eda-yml build/lowrisc_systems_top_earlgrey_0.1/syn-yosys/lowrisc_systems_top_earlgrey_0.1.eda.yml \
      --out-files sv_files.txt --out-incdirs inc_dirs.txt
"""
import argparse
import sys
from pathlib import Path

import yaml

# (substring match on the file path, reason). Checked with `in`, so keep
# these specific enough not to accidentally swallow an unrelated file.
EXCLUDES = [
    ("lowrisc_dv_pins_if_0/pins_if.sv",
     "DV-only bind interface, not part of top_earlgrey's synthesizable "
     "hierarchy; fusesoc pulls it in as a transitive dep of a DV core"),
    ("lowrisc_prim_generic_pad_wrapper_0/rtl/prim_generic_pad_wrapper.sv",
     "uses drive-strength continuous assigns (assign (weak0, pull1) ...) "
     "that sv2v's frontend cannot parse; not part of top_earlgrey's "
     "hierarchy for this netlist-level benchmark (no real IO pad ring)"),
]


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--eda-yml", required=True)
    ap.add_argument("--out-files", required=True)
    ap.add_argument("--out-incdirs", required=True)
    args = ap.parse_args()

    eda_path = Path(args.eda_yml).resolve()
    eda_dir = eda_path.parent
    d = yaml.safe_load(eda_path.read_text())

    files = []
    incdirs = set()
    excluded_hits = {e[0]: 0 for e in EXCLUDES}
    for f in d["files"]:
        if f.get("file_type") != "systemVerilogSource":
            continue
        p = (eda_dir / f["name"]).resolve()
        skip = False
        for substr, _reason in EXCLUDES:
            if substr in str(p):
                excluded_hits[substr] += 1
                skip = True
                break
        if skip:
            continue
        if not p.exists():
            print(f"warning: {p} listed in eda.yml but does not exist "
                  f"on disk, skipping", file=sys.stderr)
            continue
        # Always make the directory `-I`-reachable so `include` works, but
        # only pass non-include files as top-level sv2v arguments. Passing
        # an is_include_file (.svh, or any file only meant to be pulled in
        # via `include) as a direct positional argument makes sv2v process
        # its top-level `define statements unconditionally, in file-list
        # order — observed in practice with prim_assert_{yosys,standard}_
        # macros.svh: even though prim_assert.sv's `ifdef chain correctly
        # `includes only the dummy (SYNTHESIS) macro flavor, those other
        # two .svh files were ALSO being listed as standalone top-level
        # files later in file order, and each unconditionally redefines
        # `ASSERT — the last one processed (prim_assert_standard_macros.svh,
        # with full real SVA syntax) silently wins for every file that
        # comes after it, causing a downstream parse error on SVA sequence
        # operators sv2v can't tokenize, even though that macro flavor was
        # never supposed to be active under SYNTHESIS.
        incdirs.add(str(p.parent))
        if f.get("is_include_file"):
            continue
        files.append(str(p))

    for substr, reason in EXCLUDES:
        if excluded_hits[substr] == 0:
            print(f"note: exclude pattern '{substr}' matched nothing this "
                  f"run (fine if the dep genuinely isn't pulled in "
                  f"anymore)", file=sys.stderr)

    Path(args.out_files).write_text("\n".join(files) + "\n")
    Path(args.out_incdirs).write_text(
        "\n".join(f"-I{d}" for d in sorted(incdirs)) + "\n")

    print(f"wrote {len(files)} files to {args.out_files}")
    print(f"wrote {len(incdirs)} include dirs to {args.out_incdirs}")


if __name__ == "__main__":
    main()
