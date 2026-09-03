# top_ergo

An OpenTitan-`top_earlgrey`-derived synthesis benchmark for GenAI
timing-closure optimization research (the nebula-cogito hackathon project).
RTL → Yosys synthesis (NanGate45) → netlist, intended as the input to an
AI-driven optimization loop that fixes timing violations and improves area.

This is a **minimal extract**, not a full OpenTitan checkout: only
`top_earlgrey`'s RTL, the topgen/reggen/tlgen tooling needed to regenerate
its integration RTL, and the scripts to run the synthesis pipeline. No
docs, no DV/UVM testbenches, no unrelated tops or FPGA targets, no
Verilator simulation path (see `util/nebula/README.md`). It was cut down
from lowRISC/opentitan (branch `ergov2`) — see `notes.md` for the full
development history of how it got here.

## What's different from stock top_earlgrey

Two kinds of changes on top of stock OpenTitan:

**Added, for the benchmark itself** — 6 independent clock domains (stock
`main`/`io`/`usb`/`aon` + added `exp`/`exp2`), 9 derived/divided clocks
with real consumers, and 32 instances of 4 custom IPs
(`hw/ip/ergo_cdc_bridge`, `ergo_setup_gen`, `ergo_hold_gen`,
`ergo_cdc_hazard_gen`) that deliberately inject controllable, documented
timing violations (setup violations, CDC hold violations, bit-tearing
hazards) at real clock-domain-crossing boundaries. See `notes.md` and
`hw/top_earlgrey/data/ergo_manifest.yaml` for exactly what/where.

**Removed, to bring cell count down** — `otbn`, `hmac`, the standalone
`aes`/`usbdev` peripherals (their cipher-core / always-on-wake submodules
are still present as real internal dependencies of `csrng` and `pinmux`
respectively — see below), small analog/physical peripherals (`adc_ctrl`,
`pwm`, `pattgen`, `sysrst_ctrl`, `sensor_ctrl`), and duplicate peripheral
instances (`uart`×4→1, `i2c`×3→1, `spi_host`×2→1). `csrng`/`entropy_src`/
`edn0` and `kmac` were kept after dependency analysis showed `keymgr`/
`otp_ctrl`/`alert_handler`/`rom_ctrl`/`lc_ctrl` require them directly —
see `notes.md`'s "Baseline Yosys synthesis + pipeline formalization"
section for the details and the false starts.

Current size: **~929K standard cells** (NanGate45), down from stock
earlgrey's ~1.37M. Still well over the project's original 50-100K target
— see "Further trimming, not yet done" below. This is the accepted
"final for now" state.

## Quick start

```sh
util/nebula/build_benchmark.sh
```

See `util/nebula/README.md` for the full pipeline breakdown, what each
script does, and how to safely change clock frequencies.

## Toolchain

- Python 3.12 venv with `fusesoc`, `edalize`, and this repo's
  `python-requirements.txt` installed (topgen's `libcst` dependency wants
  3.12 specifically).
- [sv2v](https://github.com/zachjs/sv2v) (prebuilt binary).
- [Yosys](https://github.com/YosysHQ/yosys) (developed against 0.58).
- The NanGate45/FreePDK45 liberty file is included at
  `hw/top_earlgrey/syn_lib/NangateOpenCellLibrary_typical.lib`.

## What's in `hw/top_earlgrey/syn_out/`

The netlist and area report from the most recent full synthesis run of
this exact repo state, committed so the benchmark is usable without
re-running synthesis yourself first. Re-run `util/nebula/synth_yosys.sh`
(or `build_benchmark.sh`) to regenerate after any RTL/hjson change —
these files go stale the moment source changes.

## Further trimming, not yet done

~929K cells is still far above the original 50-100K target. What's left,
roughly in order of how much it would save vs. how risky it is:

- **`lc_ctrl`/`otp_ctrl`/`flash_ctrl`/`keymgr` removal** — the biggest
  remaining lever, but these are wired into `pwrmgr`'s **hand-written**
  (non-topgen-templated) power-up FSM via real handshakes (`pwr_lc`,
  `pwr_otp`, `pwr_flash`), and `rv_core_ibex.lc_cpu_en` gates the CPU
  itself. Removing them requires hand-patching pwrmgr's FSM to bypass
  those waits and tying off ~20+ downstream consumer signals to their
  *permissive* value, not their *disabled* one — get that wrong and
  Yosys will legitimately constant-propagate a stuck-disabled enable into
  deleting large amounts of otherwise-real logic (this is the exact
  failure mode called out in the project's evaluator-design notes).
- **`ibex` core config** — currently the stock, full-featured build
  (~108K cells estimated). A leaner config (drop the icache, simpler
  multiplier) would cut this down but hasn't been evaluated for how much
  it'd actually save here, or whether it changes the benchmark's realism.
- **`ergo_*` instance count / `NumStages`** — already tuned once
  (`ergo_setup_gen`'s `NumStages` 8→4). Could go further, but instance
  count is already minimal (exactly 1 per clock-domain requirement, not
  padded) and cutting `NumStages` further starts to remove the multi-stage
  pipelining challenge that's the point of that IP.
- No real STA/SDC exists yet (see `util/nebula/README.md`'s clock-leeway
  section) — `stat -liberty` gives cell count/area, not timing. That's
  separate, larger future work (the evaluator itself), not a trimming
  lever.

None of this is acted on yet — flagged for whoever picks this up next.
