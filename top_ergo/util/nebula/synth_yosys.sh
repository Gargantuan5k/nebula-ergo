#!/usr/bin/env bash
# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Synthesize the sv2v-converted top_earlgrey netlist with Yosys (open-source,
# no fusesoc/edalize involved — fusesoc's edalize yosys backend silently
# ignores custom TCL templates unless `yosys_template` is set, so this
# runs Yosys directly against the file list sv2v_convert.sh produced).
#
# Steps: hierarchy -check -> synth -> dfflibmap -> abc -> write_verilog ->
# stat -liberty (area report). No SDC / timing constraints are applied —
# this produces a structural netlist + area report, not a timed one; see
# util/nebula/README.md for what that does and doesn't tell you.
#
# This is a large, untrimmed design (~1.4M cells before any peripheral
# trimming) — expect tens of minutes and several GB of RAM. On a memory-
# constrained machine this can trip the OOM killer mid-run; if it does,
# just re-run this script (yosys has no incremental/resume state, but a
# second attempt with more free memory typically gets further or completes).
#
# Usage: SYN_LIBERTY=path/to/lib.lib util/nebula/synth_yosys.sh
#   (defaults to hw/top_earlgrey/syn_lib/NangateOpenCellLibrary_typical.lib)
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUT="${NEBULA_OUT:-build-nebula}"
VLIST="$OUT/v_files.txt"
if [ ! -f "$VLIST" ]; then
  echo "$VLIST not found — run util/nebula/sv2v_convert.sh first" >&2
  exit 1
fi

export SYN_VLIST="$(pwd)/$VLIST"
export SYN_LIBERTY="${SYN_LIBERTY:-$(pwd)/hw/top_earlgrey/syn_lib/NangateOpenCellLibrary_typical.lib}"
export SYN_OUTDIR="${SYN_OUTDIR:-$(pwd)/hw/top_earlgrey/syn_out}"
mkdir -p "$SYN_OUTDIR"

if [ ! -f "$SYN_LIBERTY" ]; then
  echo "liberty file not found: $SYN_LIBERTY" >&2
  exit 1
fi

if ! command -v yosys >/dev/null 2>&1; then
  echo "yosys not found on PATH" >&2
  exit 1
fi

echo "== running yosys synthesis (liberty: $SYN_LIBERTY) =="
echo "   this is a big design — expect tens of minutes, several GB RAM"
yosys -c hw/top_earlgrey/syn_top_earlgrey.tcl

echo ""
echo "synthesis complete:"
echo "  netlist: $SYN_OUTDIR/top_earlgrey_netlist.v"
echo "  area report: $SYN_OUTDIR/area.rpt"
