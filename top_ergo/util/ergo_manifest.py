#!/usr/bin/env python3
# Copyright Gargantuan5k, 2026 (nebula-cogito benchmark tooling).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""Generates the ergo_* benchmark ground-truth manifest from top_earlgrey.hjson.

Walks the `module:` list for instances whose `type` starts with `ergo_`
(the nebula-cogito deliberately-injected timing-closure benchmark IPs),
pulls their instance-specific data (name, base_addr, clock domains) straight
from the hjson (the single source of truth also consumed by topgen), and
combines it with static per-type metadata describing what each module type
structurally does, so the manifest can never drift from what's actually in
the design.

Usage (from repo root, inside the topgen venv):
    util/ergo_manifest.py -t hw/top_earlgrey/data/top_earlgrey.hjson \
        -o hw/top_earlgrey/data/ergo_manifest.yaml
"""

import argparse
from collections import OrderedDict

import hjson
import yaml

# Static, per-module-type metadata: what the RTL structurally does, and what
# "solved" should look like. Instance-specific fields (name, base_addr,
# clocks) are filled in dynamically below.
TYPE_METADATA = {
    "ergo_cdc_bridge": {
        "violation_type": "none (reference-correct CDC)",
        "mechanism": ("prim_fifo_async carries data clk_i -> clk_rd_i; "
                       "prim_sync_reqack reports pop events back, rate-"
                       "independent of the clk_i/clk_rd_i frequency ratio"),
        "expected_closure": (
            "n/a -- this is the safe reference crossing, not a violation. "
            "Should never regress under optimization."),
        "observable": "POP_COUNT register increments as data is consumed",
    },
    "ergo_setup_gen": {
        "violation_type": "setup",
        "mechanism": ("unpipelined multiply-accumulate chain (NumStages "
                       "stages, no intermediate registers) between "
                       "operand_gen_q and chain_result, entirely within "
                       "clk_gen_i"),
        "expected_closure": (
            "closable by retiming/pipeline insertion -- NumStages natural "
            "insertion points exist, and the surrounding req/ack handshake "
            "tolerates added latency (no fixed-cycle contract)"),
        "observable": "RESULT register reflects the chain output",
    },
    "ergo_hold_gen": {
        "violation_type": "hold",
        "mechanism": ("reg_a_q (clk_a_i domain) sampled directly by a "
                       "clk_b_i-domain flop with NO synchronizer, where "
                       "clk_b_i is clk_a_i's own derived clock -- exploits "
                       "divider insertion-delay skew"),
        "expected_closure": (
            "NOT closable by retiming alone -- requires either inserting a "
            "proper synchronizer (functional change to the crossing, "
            "should still pass EQY since the observable protocol via "
            "CAPTURED is unchanged) or hold-buffer insertion if margin "
            "allows"),
        "observable": "CAPTURED register (torn/incoherent value is expected pre-fix)",
    },
    "ergo_cdc_hazard_gen": {
        "violation_type": "cdc_data_integrity",
        "mechanism": ("free-running counter in clk_a_i crossed two ways "
                       "into clk_b_i: unsynchronized direct capture "
                       "(hazard) vs. Gray-coded + prim_flop_2sync "
                       "(reference); self-checking comparator"),
        "expected_closure": (
            "fix the unsafe path (Gray-code it, or gate it with a proper "
            "handshake) so MISMATCH_COUNT stops incrementing"),
        "observable": (
            "MISMATCH_COUNT register -- nonzero and still climbing is the "
            "ground-truth signal the hazard is present and being exercised"),
    },
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--topcfg", "-t", required=True)
    parser.add_argument("--outfile", "-o", required=True)
    args = parser.parse_args()

    with open(args.topcfg, "r") as ftop:
        topcfg = hjson.load(ftop, use_decimal=True, object_pairs_hook=OrderedDict)

    entries = []
    for mod in topcfg["module"]:
        mod_type = mod["type"]
        if not mod_type.startswith("ergo_"):
            continue
        meta = TYPE_METADATA.get(mod_type)
        if meta is None:
            raise SystemExit(f"no TYPE_METADATA entry for module type {mod_type!r} "
                              f"(instance {mod['name']!r}) -- add one before regenerating")

        clocks = {port: (src if isinstance(src, str) else src.get("clock"))
                  for port, src in mod.get("clock_srcs", {}).items()}

        entries.append({
            "instance": mod["name"],
            "module_type": mod_type,
            "base_addr": mod["base_addr"],
            "clocks": dict(clocks),
            "violation_type": meta["violation_type"],
            "mechanism": meta["mechanism"],
            "expected_closure": meta["expected_closure"],
            "observable": meta["observable"],
        })

    with open(args.outfile, "w") as fout:
        fout.write("# Auto-generated by util/ergo_manifest.py -- do not hand-edit.\n")
        fout.write(f"# Source of truth: {args.topcfg}\n")
        fout.write("# Regenerate whenever the module: list or ergo_* RTL changes.\n\n")
        yaml.dump({"ergo_instances": entries}, fout, sort_keys=False, width=100)

    print(f"Wrote {len(entries)} ergo_* instances to {args.outfile}")


if __name__ == "__main__":
    main()
