#!/usr/bin/env bash
# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# End-to-end pipeline: topgen -> sv2v -> Yosys synthesis -> netlist + area
# report.
#
# This is what you should run — no prior conversation with an AI assistant
# required. Each step is also its own standalone script (run_topgen.sh,
# sv2v_convert.sh, synth_yosys.sh) if you only need to re-run one stage,
# e.g. after a clock-only change (util/nebula/clocks.py set ...) you only
# need topgen + sv2v + synth.
#
# Note: this repo is a minimal extract of top_earlgrey (the full OpenTitan
# tree it was cut from also has a Verilator functional-simulation path,
# intentionally not included here — it pulls in a large amount of DV-only
# infrastructure this synthesis-only benchmark doesn't need. See README.md.
#
# Usage:
#   util/nebula/build_benchmark.sh                 # full pipeline
#   util/nebula/build_benchmark.sh --skip-topgen    # if you haven't touched
#                                                    # the hjson since last run
#
# Requires: a Python 3.12 venv with fusesoc/topgen/edalize (see
# util/nebula/_venv.sh), sv2v (see util/nebula/sv2v_convert.sh), Yosys.
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0"/../..)"

SKIP_TOPGEN=0
for arg in "$@"; do
  case "$arg" in
    --skip-topgen) SKIP_TOPGEN=1 ;;
    -h|--help)
      sed -n '2,21p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "unknown argument: $arg (see --help)" >&2
      exit 1
      ;;
  esac
done

step() { echo ""; echo "########## $1 ##########"; }

if [ "$SKIP_TOPGEN" -eq 0 ]; then
  step "1/4 topgen"
  util/nebula/run_topgen.sh
else
  step "1/4 topgen (skipped)"
fi

step "2/4 sv2v conversion"
util/nebula/sv2v_convert.sh

step "3/4 Yosys synthesis"
util/nebula/synth_yosys.sh

step "4/4 SDC generation"
util/nebula/gen_sdc.py

echo ""
echo "########## done ##########"
echo "netlist:     hw/top_earlgrey/syn_out/top_earlgrey_netlist.v"
echo "area report: hw/top_earlgrey/syn_out/area.rpt"
echo "SDC:         hw/top_earlgrey/syn_out/top_earlgrey.sdc"
