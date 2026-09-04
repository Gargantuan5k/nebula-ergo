#!/usr/bin/env bash
# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Regenerate top_earlgrey RTL (clkmgr, rstmgr, pinmux, top_earlgrey.sv, ...)
# from hw/top_earlgrey/data/top_earlgrey.hjson, then regenerate the
# ergo_manifest.yaml reproducibility manifest to match.
#
# Requires a Python 3.12 venv with OpenTitan's topgen deps (libcst needs
# 3.12 specifically). Point NEBULA_VENV at it, or activate one yourself
# before running this script.
#
# Usage: util/nebula/run_topgen.sh
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source util/nebula/_venv.sh

PYVER="$(python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')"
if [ "$PYVER" != "3.12" ]; then
  echo "warning: python3 is $PYVER, topgen's libcst dependency wants 3.12" \
       "— continuing, but a version-mismatch failure here is a known gotcha" >&2
fi

echo "== clock config sanity check =="
python3 util/nebula/clocks.py check || {
  echo "clock config has hard failures — fix before running topgen" \
       "(see util/nebula/clocks.py check output above)" >&2
  exit 1
}

echo "== running topgen =="
( cd hw/top_earlgrey && ../../util/topgen.py -t data/top_earlgrey.hjson -o . -v )

echo "== regenerating ergo_manifest.yaml =="
python3 util/ergo_manifest.py \
  -t hw/top_earlgrey/data/top_earlgrey.hjson \
  -o hw/top_earlgrey/data/ergo_manifest.yaml

cat <<'EOF'

topgen complete.

Known non-fatal noise: an is_pow2() assertion may fail while generating
xbar_cover.cfg (DV coverage-exclusion config) for one crossbar. It's caught
internally by topgen (util/tlgen/generate_tb.py's bare except), doesn't
abort generation, and doesn't touch RTL/synthesis — safe to ignore.

Known two-step gotcha: if you just added a *new master clock* (not just
changed an existing frequency), and this run failed validate_top() after
adding both `resets.nodes` entries and the matching rstmgr `clock_srcs`
declaration in the same pass, split it: add `resets.nodes` first, run
topgen once (rstmgr regenerates its ports from resets.nodes alone), THEN
add the `clock_srcs` declaration and run topgen again. Re-running as-is
does not self-heal a mismatch created this way.

Next: util/nebula/sv2v_convert.sh
EOF
