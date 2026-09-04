# nebula pipeline scripts

Reproducible, no-AI-required scripts to regenerate this benchmark from the
`top_earlgrey.hjson` source of truth through to a synthesized Yosys netlist.
See the repo-root `README.md` for what this repo is and toolchain setup.

Note: this is a minimal extract of top_earlgrey, not a full OpenTitan
checkout — there is no Verilator functional-simulation path here (it pulls
in a large amount of DV-only infrastructure — DPI models, memutil/simutil,
sim_sram — that this synthesis-only benchmark doesn't need). If you need
that, it exists in the full lowRISC/opentitan tree this was cut from.

## Quick start

```sh
util/nebula/build_benchmark.sh   # full pipeline
```

Output: `hw/top_earlgrey/syn_out/top_earlgrey_netlist.v` +
`hw/top_earlgrey/syn_out/area.rpt` + `hw/top_earlgrey/syn_out/top_earlgrey.sdc`.

## Scripts, in pipeline order

| Script | What it does |
|---|---|
| `clocks.py` | Show/validate/edit clock frequencies & divisors in `top_earlgrey.hjson` |
| `run_topgen.sh` | Regenerate clkmgr/rstmgr/pinmux/top_earlgrey.sv/etc. from the hjson |
| `gen_sv2v_filelist.py` | Turn fusesoc's own dependency resolution (`eda.yml`) into an sv2v file list |
| `sv2v_convert.sh` | Convert the design to plain Verilog with sv2v (Yosys's native `-sv` frontend can't parse several constructs this design uses) |
| `synth_yosys.sh` | Run Yosys synthesis on the converted netlist, produce `area.rpt` |
| `gen_sdc.py` | Generate `top_earlgrey.sdc` (clocks + clock groups) from the hjson and clkmgr's divider topology |
| `build_benchmark.sh` | Runs all of the above in order |
| `package_release.sh` | Assemble the exact minimal file set handed to the optimization-engine team (netlist + SDC + liberty + a trimmed area summary + `RELEASE_MANUAL.md`) into `release/` — see the repo-root `RELEASE_MANUAL.md` for the full usage contract and why RTL/`ergo_manifest.yaml`/`notes.md` are deliberately excluded |

Each script is standalone — re-run just the one you need. A clock-only
change, for example, only needs `clocks.py set` → `run_topgen.sh` →
`sv2v_convert.sh` → `synth_yosys.sh`.

## Changing clock frequencies

```sh
util/nebula/clocks.py show                        # current clock tree
util/nebula/clocks.py check                        # validate current config
util/nebula/clocks.py set main --freq 120000000     # change a master's frequency
util/nebula/clocks.py set exp_div2 --div 4          # change a derived clock's divisor
```

`set` writes the hjson in place and re-runs `check` automatically, refusing
(unless `--force`) to leave the file in a state that fails a hard check.

### What's actually safe to change, and why

This project's clock tree (`hw/top_earlgrey/data/top_earlgrey.hjson`,
`clocks.srcs`/`clocks.derived_srcs`) has real constraints enforced at
different levels — some by RTL assertions, some by topgen's own code
generation, some purely by convention. `clocks.py check` verifies the ones
that are mechanically checkable:

1. **Every derived clock's divisor must be even.**
   `prim_generic_clock_div.sv` has `` `ASSERT_INIT(DivEven_A, (Divisor % 2) == 0)`` —
   an odd divisor is a hard elaboration-time failure in Verilator, not just
   a lint warning.
2. **A derived clock's declared `freq` must exactly equal `src_freq / div`.**
   topgen doesn't compute this itself — the hjson's `freq` field is a
   label it trusts verbatim. A mismatch doesn't break synthesis, but it
   silently mislabels the clock everywhere downstream (register docs, and
   any future SDC generation that reads this field instead of recomputing
   it).
3. **Every non-`aon` master frequency must be an integer multiple of `aon`'s
   frequency (200 kHz).** clkmgr's frequency-measurement threshold
   generation (`hw/ip_templates/clkmgr/data/clkmgr.hjson.tpl`) computes
   `ratio = int(freq / aon_freq)` for each measured master and bakes it
   into register reset values. Python's `int()` truncates rather than
   erroring on a non-exact ratio, so a non-multiple frequency doesn't fail
   topgen — it silently produces a miscalibrated glitch-detection window.
4. **`aon` itself is locked** (`clocks.py` refuses to change it without
   `--force-aon`). It's structurally load-bearing: rstmgr's POR root,
   pwrmgr's hand-written (non-templated) low-power FSM, and several
   wake-detect peripherals all assume it. topgen's own derived-clock
   machinery (`util/topgen/clocks.py`) throws `KeyError` if you try to
   derive a clock *from* `aon` — it structurally bypasses clkmgr by design.
5. **`usb` conventionally wants to stay 48 MHz** (warning only, not
   enforced). Nothing in this synthesis-only benchmark's toolchain cares,
   but it's the real USB full-speed PHY rate — changing it makes the
   design less representative of anything that could tape out.

None of this tells you a *maximum frequency* the design can run at and
still close timing — that's a question for static timing analysis (STA),
not something topgen or Yosys's structural synthesis (`stat -liberty`, no
timing constraints applied) can answer. `synth_yosys.sh` itself still
only produces a cell-count/area report, not a timing report — no STA tool
runs as part of this repo's own pipeline.

What *does* exist now: `gen_sdc.py` generates
`hw/top_earlgrey/syn_out/top_earlgrey.sdc` — `create_clock`/
`create_generated_clock` for all 15 clocks (6 masters + 9 derived, read
straight from this same hjson) plus `set_clock_groups -asynchronous`
between independent-oscillator families. See "SDC generation" below for
what it does and doesn't model. It's regenerated on every
`build_benchmark.sh` run (step 4/4), so it never goes stale after a
frequency change — but nothing in this repo actually *runs* STA against
it yet. That's separate, larger future work (an OpenSTA integration,
tracked as the evaluator itself) — the SDC is meant to be a ready input
for that, not proof this design meets it.

## SDC generation

`gen_sdc.py` derives the SDC entirely from things already declared
elsewhere — `top_earlgrey.hjson`'s clock frequencies (via `clocks.py`'s
`ClockConfig`) and clkmgr's divider topology, which follows a fixed
topgen naming convention (every derived clock `<name>` comes from an
instance `u_no_scan_<name>_div` inside `u_clkmgr_aon`, output pin
`clk_o` — verified against both `clkmgr.sv` and the synthesized
netlist). Nothing about it is hand-maintained, so it can't drift from the
hjson the way a hand-written SDC would.

Two scoping decisions worth knowing if you extend this:

- **Clock groups are asynchronous by oscillator family, not by pair.**
  Every clock derived from the same master (e.g. `exp`, `exp_div2`,
  `exp_div8`) stays in one `set_clock_groups` group, so
  `ergo_hold_gen`/`ergo_cdc_hazard_gen`'s deliberate violations — which
  cross between a master and its own derived clock, a real synchronous
  relationship — are actually analyzed, not excluded. Clocks from
  *different* families (e.g. `io_div4` vs. `exp`) are asynchronous,
  matching every genuinely independent-oscillator crossing in this
  design, including `ergo_cdc_bridge`'s reference-correct crossings
  (`prim_fifo_async` + `prim_sync_reqack`), which must not be flagged as
  ordinary synchronous setup/hold violations.
- **No input/output delay constraints on top-level IO/pad ports**
  (`mio_*`, `dio_*`, `ast_*`, `flash_*`, `otp_*`, `scan_*`, ...). None of
  this benchmark's injected violations touch chip-boundary ports — they're
  all IP-internal — and this repo has no real package/board timing spec
  to derive plausible delay values from. Fabricating IO timing with no
  grounding would be worse than leaving it unconstrained; if this ever
  needs to model IO boundary timing, that requires an actual spec to
  derive it from, not invented numbers.

## sv2v conversion notes

`gen_sv2v_filelist.py` reads fusesoc's own `eda.yml` (written by
`fusesoc run --target=syn --setup`) rather than re-deriving the file list
by hand — that's the actual dependency resolution this project's `.core`
files declare, ordering included. Two things worth knowing if you extend
this:

- A small number of files are excluded by name (see `EXCLUDES` in the
  script) — `pins_if.sv` (DV-only) and `prim_generic_pad_wrapper.sv`
  (drive-strength continuous assigns sv2v can't parse, and not part of
  this benchmark's synthesizable hierarchy — no real IO pad ring here).
- Files fusesoc marks `is_include_file: true` are added to sv2v's `-I`
  search path but **not** passed as top-level file arguments. Passing an
  include-only file as a direct argument makes sv2v process its top-level
  `` `define ``s unconditionally in file-list order — this is what caused a
  real bug during this project's own development: `prim_assert_standard_
  macros.svh` (the full real-SVA `` `ASSERT `` definition) was being read as
  a standalone top-level file *after* `prim_assert.sv` had already
  correctly `` `include``d the SYNTHESIS-safe dummy-macro version, silently
  overriding it for every file processed afterward and breaking on SVA
  sequence syntax (`[*2]`, etc.) sv2v's parser doesn't support.

`sv2v_convert.sh` always re-runs `fusesoc ... --setup` first — never reads
a stale `build/` tree. A `build/` copy of a file does not update itself
when you edit the source; this bit us once (a source fix to
`prim_assert.sv` had no effect until the next fresh `--setup`).

## Toolchain

- fusesoc/topgen/edalize: project venv (Python 3.12 — topgen's `libcst`
  dependency wants that specific version). `util/nebula/_venv.sh` activates
  `$NEBULA_VENV` (default `~/.venvs/opentitan`) if no venv is already active.
- sv2v: prebuilt binary, not built from source. `sv2v_convert.sh` looks for
  it on `PATH`, then at `../sv2v-Linux/sv2v` (this project's dev layout),
  then respects `$SV2V` if set.
- Yosys: needs to be on `PATH`. This was developed/verified against Yosys
  0.58.
- Liberty target: NanGate45/FreePDK45
  (`hw/top_earlgrey/syn_lib/NangateOpenCellLibrary_typical.lib`), chosen
  for zero extra setup friction (matches `hw/ip/aes/pre_syn/`'s existing
  flow). The RTL only uses generic `prim_*` primitives, so switching
  liberty targets (e.g. to sky130) is a `SYN_LIBERTY=...` change, not an
  RTL rewrite — pass it as an env var to `synth_yosys.sh`.
