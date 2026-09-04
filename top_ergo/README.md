# top_ergo

## File Structure:
```
top_ergo/
├── README.md                 (what this repo is, what's in/out, further-trimming notes)
├── notes.md                  (full dev history/log of how this benchmark was built)
├── LICENSE
├── pyproject.toml, python-requirements.txt, apt-requirements.txt, tool_requirements.py    (Python/toolchain deps for topgen/reggen/fusesoc)
├── hw/
│   ├── ip/                    (the kept IPs' RTL + register-map hjson (30 dirs: aes, csrng,
│   │                          keymgr, kmac, otp_ctrl, lc_ctrl, rv_core_ibex, the 4 ergo_*
│   │                          benchmark IPs, prim/prim_generic primitives, tlul, etc.))
│   ├── ip_templates/          (clkmgr/rstmgr/pwrmgr/alert_handler/flash_ctrl/rv_plic
│   │                          templates (topgen fills these in per-top))
│   ├── vendor/                (vendored ibex core, riscv-dbg)
│   ├── dv/                    (a couple of small shared interface files still needed
│   │                          (not the full DV/UVM tree))
│   └── top_earlgrey/          the actual top-level integration:
│       ├── data/top_earlgrey.hjson     the source of truth (clocks, resets, module list)
│       ├── ip_autogen/                 topgen-generated clkmgr/rstmgr/pwrmgr/etc RTL
│       ├── rtl/autogen/                topgen-generated top_earlgrey.sv itself
│       ├── ip/{ast,pinmux,xbar_*}/     top-specific IP instances (crossbar, pinmux, AST)
│       ├── syn_lib/                    NanGate45 liberty file
│       ├── syn_top_earlgrey.tcl        the Yosys synthesis script
│       └── syn_out/                    the actual committed results:
│                                         top_earlgrey_netlist.v (73MB gate-level netlist)
│                                         area.rpt (cell/area breakdown)
│                                         top_earlgrey.sdc (clocks + clock groups)
└── util/
    ├── topgen/, reggen/, tlgen/, ipgen/, design/  — the codegen tooling (as-is from OT)
    └── nebula/                 the pipeline scripts:
                                clocks.py, run_topgen.sh, gen_sv2v_filelist.py,
                                sv2v_convert.sh, synth_yosys.sh, gen_sdc.py,
                                build_benchmark.sh
```

# What is `ergo` ?
An OpenTitan-`top_earlgrey`-derived synthesis benchmark for GenAI
timing-closure optimization research (for the Nebula@BITS hackathon by Astera Labs).
RTL → Yosys synthesis (NanGate45) → netlist, intended as the input to an
AI-driven optimization loop that fixes timing violations and improves area.

This is a **minimal extract**, not a full OpenTitan checkout: only
`top_earlgrey`'s RTL, the topgen/reggen/tlgen tooling needed to regenerate
its integration RTL, and the scripts to run the synthesis pipeline. No
docs, no DV/UVM testbenches, no unrelated tops or FPGA targets, no
Verilator simulation path (see `util/nebula/README.md`). It was cut down
from lowRISC/opentitan (branch `ergov2`) — see `notes.md` for the full
development history of how it got here.

## What is different from stock `top_earlgrey` ?

Two kinds of changes on top of stock OpenTitan:

**Added, for the benchmark itself**:  6 independent clock domains (stock
`main`/`io`/`usb`/`aon` + added `exp`/`exp2`), 9 derived/divided clocks
with real consumers, and 32 instances of 4 custom IPs
(`hw/ip/ergo_cdc_bridge`, `ergo_setup_gen`, `ergo_hold_gen`,
`ergo_cdc_hazard_gen`) that deliberately inject controllable, documented
timing violations (setup violations, CDC hold violations, bit-tearing
hazards) at real clock-domain-crossing boundaries. See `notes.md` and
`hw/top_earlgrey/data/ergo_manifest.yaml` for exactly what/where.

**Removed, to bring cell count down**: `otbn`, `hmac`, the standalone
`aes`/`usbdev` peripherals (their cipher-core / always-on-wake submodules
are still present as real internal dependencies of `csrng` and `pinmux`
respectively — see below), small analog/physical peripherals (`adc_ctrl`,
`pwm`, `pattgen`, `sysrst_ctrl`, `sensor_ctrl`), and duplicate peripheral
instances (`uart`×4→1, `i2c`×3→1, `spi_host`×2→1). `csrng`/`entropy_src`/
`edn0` and `kmac` were kept after dependency analysis showed `keymgr`/
`otp_ctrl`/`alert_handler`/`rom_ctrl`/`lc_ctrl` require them directly —
see `notes.md`'s "Baseline Yosys synthesis + pipeline formalization"
section for the details and the false starts.

Current size: **854,531 standard cells** (NanGate45), down from stock
earlgrey's ~1.37M. Still well over the project's original 50-100K target
— see "Further trimming, not yet done" below.

## Hackathon design requirements

The hackathon's stated design requirements for the RTL/netlist under test,
and how this benchmark satisfies each:

| requirement | status |
|---|---|
| ≥5 independent async master clock domains | **6**: `main`, `io`, `usb`, `aon`, `exp`, `exp2` |
| ≥1 generated clock per master | **5 of the 6.** `main`, `io`, `usb`, `exp`, `exp2` each have 1-2 derived clocks (9 total, see `util/nebula/clocks.py show`). `aon` doesn't — real OpenTitan's `clkmgr` structurally forbids deriving a clock *from* `aon` (topgen's own generator code raises on it; see `util/nebula/README.md`'s "What's actually safe to change" §4). Rather than bolt on a synthetic divider purely to check this box, `aon` is counted as a genuine **bonus 6th master domain**, beyond the 5 required — the other 5 (`main`/`io`/`usb`/`exp`/`exp2`) independently satisfy "at least 5 masters, each with ≥1 generated clock" on their own. |
| Clock Domain Crossings (CDC) between async domains | **yes** — `ergo_cdc_bridge`×9 (reference-correct: real `prim_fifo_async` + `prim_sync_reqack`), plus `ergo_hold_gen`×7 / `ergo_cdc_hazard_gen`×7 (deliberate violations) |
| clock divider logic, multiple division ratios | **yes** — ÷2, ÷4, ÷6, ÷8, ÷10 all present across the 9 derived clocks |
| ~50K+ standard cells | **yes** — 854,531 (NanGate45) |

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

The netlist, area report, and SDC from the most recent full pipeline run
of this exact repo state, committed so the benchmark is usable without
re-running synthesis yourself first:

- `top_earlgrey_netlist.v` / `area.rpt` — from `synth_yosys.sh`, a
  structural netlist and cell-count/area report. No timing constraints
  are applied during synthesis itself (Yosys's generic `synth` here is
  not timing-driven).
- `top_earlgrey.sdc` — from `gen_sdc.py`, `create_clock`/
  `create_generated_clock` for all 15 clocks plus clock-group exceptions
  for the genuinely asynchronous crossings. This is the input a real STA
  run (e.g. OpenSTA) needs to actually report the timing violations this
  benchmark exists to inject — see `util/nebula/README.md`'s "SDC
  generation" section for exactly what it does and doesn't model (notably:
  no input/output delay on top-level IO ports). No STA tool runs as part
  of this repo's own pipeline yet; that's separate future work.

Re-run `util/nebula/build_benchmark.sh` to regenerate all three after any
RTL/hjson change — they go stale the moment source changes.

## Further trimming, not yet done

854K cells is still far above the original 50-100K target — and, per the
hackathon rules, the design size directly affects the runtime/API cost
whoever builds the GenAI optimizer pays per iteration against this
benchmark, so trimming further is a real lever on the team's overall
score, not just housekeeping. What's left, roughly in order of how much
it would save vs. how risky it is:

- **`ibex` core config — done.** Was the stock, full-featured build
  (~179K area). Turning off `ICache`/`ICacheECC`/`ICacheScramble` and
  dropping `PMPNumRegions` 16→4 (both pure `param_decl` edits, no RTL
  surgery) cut it to ~109K area — a ~39% reduction on that block alone,
  and it accounted for essentially the entire design-wide 898,268→854,531
  cell drop (every other IP came back unchanged to 3 significant figures
  in the same run). `RV32B`/`RV32M`/`SecureIbex` were left alone —
  changing those trades away real ISA/security-countermeasure
  functionality, not just synthesis fat.
- **`kmac`/`entropy_src`/`csrng` cluster (~252K cells, ~28% of the
  design)** — bigger than initially scoped, and not previously called out
  here. Entangled: `kmac.app` has exactly three consumers —
  `keymgr`, `lc_ctrl`, **and `rom_ctrl`** (verified against
  `top_earlgrey.hjson`'s `inter_module` block) — so `kmac` survives even
  a full `keymgr`+`lc_ctrl` removal unless `rom_ctrl`'s digest check is
  also stubbed, which is a real change to the boot/security model, not a
  trim. `entropy_src`/`csrng` feed `edn`, which fans out to `keymgr`,
  `otp_ctrl`, `ast`, `kmac` itself, and ibex's own countermeasures — same
  entanglement. Needs its own dependency audit before it's a safe target.
- **`lc_ctrl`/`otp_ctrl`/`flash_ctrl`/`keymgr` removal (~188K cells,
  ~21%)** — these are wired into `pwrmgr`'s **hand-written**
  (non-topgen-templated) power-up FSM via real handshakes (`pwr_lc`,
  `pwr_otp`, `pwr_flash`), and `rv_core_ibex.lc_cpu_en` gates the CPU
  itself. Removing them requires hand-patching pwrmgr's FSM to bypass
  those waits and tying off ~20+ downstream consumer signals to their
  *permissive* value, not their *disabled* one — get that wrong and
  Yosys will legitimately constant-propagate a stuck-disabled enable into
  deleting large amounts of otherwise-real logic (this is the exact
  failure mode called out in the project's evaluator-design notes).
- **`ergo_*` instance count / `NumStages`** — already tuned once
  (`ergo_setup_gen`'s `NumStages` 8→4). Could go further, but instance
  count is already minimal (exactly 1 per clock-domain requirement, not
  padded) and cutting `NumStages` further starts to remove the multi-stage
  pipelining challenge that's the point of that IP.
- **Yosys-level `share`/`opt -full` — tried, not worth it.** Added ahead
  of `abc` in `syn_top_earlgrey.tcl` to see if resource sharing / a full
  optimization sweep found anything the default `synth` script's own
  passes missed. Measured effect: none (every block held its cell count
  to 3 significant figures) — for ~35 extra minutes of runtime and a peak
  memory footprint (~8GB) that risked tripping an OOM killer on a
  memory-constrained machine. Not worth keeping; don't retry this without
  a specific reason to think it'll behave differently.
- No real STA exists in this repo's own pipeline — `top_earlgrey.sdc`
  (see `util/nebula/README.md`'s "SDC generation" section) gives clocks
  and clock-group exceptions, but nothing here runs an STA tool against
  it, and `stat -liberty` gives cell count/area, not timing. That's the
  separate "RTL timing analysis framework" deliverable (OpenSTA is in the
  hackathon's own tools list) — this benchmark's job is just to hand that
  piece an SDC it can actually use, which it now can.

