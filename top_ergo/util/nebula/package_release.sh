#!/usr/bin/env bash
# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Assemble the exact, minimal set of files this benchmark hands over to the
# optimization-engine team: the synthesized netlist, its SDC, the liberty
# file it was mapped against, a trimmed area summary, and the usage manual.
# Deliberately excludes everything else in this repo (RTL, ergo_manifest.yaml,
# notes.md, the full multi-pass area.rpt log, ...) — see RELEASE_MANUAL.md §2/§9
# for why. Re-run this after any resynthesis to keep the release bundle current.
#
# Usage: util/nebula/package_release.sh [outdir]   (default: release/)
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

OUT="${1:-release}"
SYN_OUT="hw/top_earlgrey/syn_out"
LIBERTY="hw/top_earlgrey/syn_lib/NangateOpenCellLibrary_typical.lib"

for f in "$SYN_OUT/top_earlgrey_netlist.v" "$SYN_OUT/top_earlgrey.sdc" "$SYN_OUT/area.rpt" "$LIBERTY" "RELEASE_MANUAL.md"; do
  if [ ! -f "$f" ]; then
    echo "missing required input: $f — run util/nebula/build_benchmark.sh first" >&2
    exit 1
  fi
done

rm -rf "$OUT"
mkdir -p "$OUT"

cp "$SYN_OUT/top_earlgrey_netlist.v" "$OUT/"
cp "$SYN_OUT/top_earlgrey.sdc" "$OUT/"
cp "$LIBERTY" "$OUT/"
cp "RELEASE_MANUAL.md" "$OUT/"

# area.rpt is a multi-pass synthesis log (every intermediate `stat` snapshot
# plus a full recursive per-submodule dump, not just the final summary) —
# extract only the final "Count/Area including submodules" totals block (the
# last occurrence of that header) so nobody accidentally reads a stale
# mid-synthesis or per-submodule-recursion number instead of the real total.
awk '/Count including submodules/ { buf=""; capture=1 }
     capture { buf = buf $0 ORS }
     END { printf "%s", buf }' "$SYN_OUT/area.rpt" > "$OUT/reference_area_summary.txt"

echo "wrote $OUT/:"
ls -la "$OUT"
echo ""
echo "total size:"
du -sh "$OUT"
