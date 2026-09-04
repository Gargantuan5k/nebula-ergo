#!/usr/bin/env bash
# Copyright Gargantuan5k, 2026.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Convert top_earlgrey's SystemVerilog to plain Verilog with sv2v, for
# Yosys (whose native `-sv` frontend can't parse several constructs this
# design uses: struct/array assignment patterns, drive-strength continuous
# assigns, package-scoped port types). This is a from-scratch, reproducible
# regeneration: it always re-runs `fusesoc ... --setup` first, so it never
# reads a stale build/ tree left over from a previous run or a source edit.
#
# Output: one converted_output.v (via sv2v's -w adjacent) written next to
# every original .sv file it converts, under build/. synth_yosys.sh reads
# the resulting file list from build-nebula/v_files.txt.
#
# Requires: sv2v (prebuilt binary — https://github.com/zachjs/sv2v/releases).
# Point SV2V at it, or place it at ../sv2v-Linux/sv2v relative to this repo
# (this project's dev setup), or put it on PATH.
#
# Usage: util/nebula/sv2v_convert.sh
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source util/nebula/_venv.sh

if [ -n "${SV2V:-}" ]; then
  :
elif command -v sv2v >/dev/null 2>&1; then
  SV2V="$(command -v sv2v)"
elif [ -x "../sv2v-Linux/sv2v" ]; then
  SV2V="../sv2v-Linux/sv2v"
else
  echo "sv2v not found. Download a prebuilt binary from" \
       "https://github.com/zachjs/sv2v/releases, then either put it on" \
       "PATH, place it at ../sv2v-Linux/sv2v, or set SV2V=/path/to/sv2v." >&2
  exit 1
fi
echo "using sv2v: $SV2V"

OUT="${NEBULA_OUT:-build-nebula}"
mkdir -p "$OUT"

echo "== clock config sanity check =="
python3 util/nebula/clocks.py check || {
  echo "clock config has hard failures — fix before converting" >&2
  exit 1
}

echo "== fusesoc: resolving top_earlgrey's syn fileset (fresh) =="
fusesoc --cores-root=. run --target=syn --setup lowrisc:systems:top_earlgrey

EDA_YML="build/lowrisc_systems_top_earlgrey_0.1/syn-yosys/lowrisc_systems_top_earlgrey_0.1.eda.yml"
if [ ! -f "$EDA_YML" ]; then
  echo "expected eda.yml not found at $EDA_YML — fusesoc's output layout" \
       "may have changed" >&2
  exit 1
fi

echo "== building sv2v file list from fusesoc's own resolution =="
python3 util/nebula/gen_sv2v_filelist.py \
  --eda-yml "$EDA_YML" \
  --out-files "$OUT/sv_files.txt" \
  --out-incdirs "$OUT/inc_dirs.txt"

echo "== running sv2v =="
# SYNTHESIS / SYNTHESIS_MEMORY_BLACK_BOXING are OpenTitan-native macros
# (not sv2v- or Yosys-specific) that gate out simulation-only code:
# behavioral memory models, plusargs-based debug loaders, and (via
# prim_assert.sv's dummy macro flavor) all SVA assertions/covers/assumes.
# shellcheck disable=SC2046
"$SV2V" --define=SYNTHESIS --define=SYNTHESIS_MEMORY_BLACK_BOXING \
  -w adjacent \
  $(cat "$OUT/inc_dirs.txt") \
  $(cat "$OUT/sv_files.txt") \
  > "$OUT/sv2v_out.log" 2>&1
RC=$?
if [ "$RC" -ne 0 ] || [ -s "$OUT/sv2v_out.log" ]; then
  echo "sv2v reported errors/warnings — see $OUT/sv2v_out.log" >&2
  tail -40 "$OUT/sv2v_out.log" >&2
  [ "$RC" -ne 0 ] && exit "$RC"
fi

sed 's/\.sv$/.v/' "$OUT/sv_files.txt" > "$OUT/v_files.txt"
missing=0
while read -r f; do [ -f "$f" ] || { echo "missing: $f"; missing=$((missing + 1)); }; done < "$OUT/v_files.txt"
if [ "$missing" -ne 0 ]; then
  echo "$missing expected .v output(s) missing after sv2v — see above" >&2
  exit 1
fi

echo ""
echo "sv2v conversion complete: $(wc -l < "$OUT/v_files.txt") .v files"
echo "file list: $OUT/v_files.txt"
echo "Next: util/nebula/synth_yosys.sh"
