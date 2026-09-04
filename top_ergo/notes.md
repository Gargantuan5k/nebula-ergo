# Dev Log for operntitan customization

## Building Earlgrey to verify toolchain and OT setup

**error received:**
```
Target //sw/device/tests:uart_smoketest_sim_verilator failed to build
Use --verbose_failures to see the command lines of failed build steps.
INFO: Elapsed time: 37.271s, Critical Path: 35.58s
INFO: 34 processes: 3 internal, 30 linux-sandbox, 1 local.
ERROR: Build did NOT complete successfully
//sw/device/tests:uart_smoketest_sim_verilator                  FAILED TO BUILD

Executed 0 out of 1 test: 1 fails to build.
FAILED: 
    Fetching ...ository @@rules_rust~~rust~rust_tock__riscv32imc-unknown-none-elf__nightly_tools; starting 36s
    Fetching https://static.rust-lang.org/...t-std-nightly-riscv32imc-unknown-none-elf.tar.xz; 3.0 MiB (36.9%)
```

**FIX**
```
1. Open hw/top_earlgrey/dv/verilator/chip_sim.core
2. In the sim: target's verilator_options: list (line 100-123), add a new line: - '--no-timing' anywhere in that list
3. Rerun: ./bazelisk.sh test --test_output=streamed //sw/device/tests:uart_smoketest_sim_verilator
```

**received a bunch of errors which were related to dependencies that werent installed. DOCUMNTED MOST HERE**
```SH
sudo dnf install ncurses-compat-libs
```

**ERROR**:
```
9:ERROR: /home/sid/Development/hardware/nebula-cogito/opentitan/sw/host/sphincsplus/BUILD:19:21: Generating bindings for external/sphincsplus_fips205_ipd/api.h.. failed: (Exit 101): bindgen-cli failed: error executing RustBindgen command (from target //sw/host/sphincsplus:bindgen_shake_128s_simple__bindgen) bazel-out/k8-opt-exec-ST-d57f47055a04/bin/external/rules_rust_bindgen~~rust_ext~rules_rust_bindgen__bindgen-cli-0.71.1/bindgen-cli '--allowlist-function=SPX_.*' '--allowlist-var=CRYPTO_.*' ... (remaining 32 arguments skipped)
18:ERROR: Build did NOT complete successfully
```
**FIX**
```sh
1. Open hw/dv/dpi/usbdpi/usb_monitor.c:63
2. Change uint8_t byte; → uint16_t byte;
3. Rerun: ./bazelisk.sh test --test_output=streamed //sw/device/tests:uart_smoketest_sim_verilator 2>&1 | tee /tmp/build.log
```

**ERROR**
```
13:ERROR: /home/sid/Development/hardware/nebula-cogito/opentitan/hw/BUILD:35:14: FuseSoC hw/build.verilator_real/sim-verilator/Vchip_sim_tb [for tool] failed: (Exit 1): fusesoc_build failed: error executing FuseSoC command (from target //hw:verilator_real) bazel-out/k8-opt-exec-ST-d57f47055a04/bin/util/fusesoc_build '--config=bazel-out/k8-opt-exec-ST-d57f47055a04/bin/hw/build.verilator_real.fusesoc_config.toml' '--cores-root=.' run '--flag=fileset_top' ... (remaining 7 arguments skipped)
  268:ERROR: %Warning-PINMISSING: ../src/lowrisc_dv_sim_sram_0/sim_sram.sv:68:7: Instance has missing pin: 'en_ifetch_i'
  3358:../src/lowrisc_dv_dpi_c_usbdpi_0.1/usbdpi_stream.c:507:16: error: this statement may fall through [-Werror=implicit-fallthrough=]
  3367:make: *** [Makefile:13: Vchip_sim_tb] Error 2
  3369:ERROR: Failed to build lowrisc:dv:chip_verilator_sim:0.1 : '['make']' exited with an error: 2
  3546:ERROR: Build did NOT complete successfully
```

**FIX**
Same class of issue, this time it's the comment style. hw/dv/dpi/usbdpi/usbdpi_stream.c:508 has // no break as an intentional-fallthrough marker (line 506 falls through 507-508 into the USB_TRANSFER_TYPE_INTERRUPT case on purpose, sharing the code below). GCC's -Wimplicit-fallthrough only recognizes specific comment forms (/* fallthrough */, // fallthrough, etc.) or the __attribute__((fallthrough)) statement — // no break doesn't match, so GCC treats it as unannotated and -Werror fails the build. Real intentional behavior, just needs the marker GCC actually recognizes.

```1. Open hw/dv/dpi/usbdpi/usbdpi_stream.c:508
2. Replace // no break with __attribute__((fallthrough));
3. Rerun: ./bazelisk.sh test --test_output=streamed //sw/device/tests:uart_smoketest_sim_verilator 2>&1 | tee /tmp/build.log
```

12:ERROR: /home/sid/Development/hardware/nebula-cogito/opentitan/hw/BUILD:35:14: FuseSoC hw/build.verilator_real/sim-verilator/Vchip_sim_tb [for tool] failed: (Exit 1): fusesoc_build failed: error executing FuseSoC command (from target //hw:verilator_real) bazel-out/k8-opt-exec-ST-d57f47055a04/bin/util/fusesoc_build '--config=bazel-out/k8-opt-exec-ST-d57f47055a04/bin/hw/build.verilator_real.fusesoc_config.toml' '--cores-root=.' run '--flag=fileset_top' ... (remaining 7 arguments skipped)
  270:ERROR: %Warning-PINMISSING: ../src/lowrisc_dv_sim_sram_0/sim_sram.sv:68:7: Instance has missing pin: 'en_ifetch_i'
  3360:../src/lowrisc_dv_dpi_tcp_server_0.1/tcp_server.c:245:25: error: logical ‘or’ of equal expressions [-Werror=logical-op]
  3364:../src/lowrisc_dv_dpi_tcp_server_0.1/tcp_server.c:272:27: error: logical ‘or’ of equal expressions [-Werror=logical-op]
  3370:make: *** [Makefile:13: Vchip_sim_tb] Error 2
  3372:ERROR: Failed to build lowrisc:dv:chip_verilator_sim:0.1 : '['make']' exited with an error: 2
  3549:ERROR: Build did NOT complete successfully

  Searched for 1 pattern, read 3 files, ran 2 shell commands

Different situation — this one's not a bug, and shouldn't be "fixed" by changing the logic. hw/dv/dpi/common/tcp_server/tcp_server.c:245 and :272 both do errno == EAGAIN || errno == EWOULDBLOCK. On Linux, EAGAIN and EWOULDBLOCK are literally the same value (11) — checking both is the standard, correct, portable idiom for "would block" (some POSIX systems define them differently). GCC's -Wlogical-op doesn't know that and flags it as a duplicate comparison; a well-known false positive for this exact pattern, not a real defect. Editing the comparison would make the code less portable, not more correct.

No global -Werror/-Wall source for this in the repo's own .core/.bazelrc files — it's coming from Bazel's default toolchain flags, not something OT set. Rather than chase that down, silence it locally at the two call sites — standard, safe, doesn't touch build config.

1. Open hw/dv/dpi/common/tcp_server/tcp_server.c
2. At line 245, wrap the if line:
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wlogical-op"
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
#pragma GCC diagnostic pop
3. Do the same around line 272 (the put_byte version)
4. Rerun: ./bazelisk.sh test --test_output=streamed //sw/device/tests:uart_smoketest_sim_verilator 2>&1 | tee /tmp/build.log
5. If it fails: grep -n -iE "error:|%Error|undefined reference|fatal error|^make:" /tmp/build.log | tail -20 and paste

### TESTS PASSED!!
**Commit everything:**
```sh
git add hw/dv/dpi/common/tcp_server/tcp_server.c hw/dv/dpi/usbdpi/usb_monitor.c hw/dv/dpi/usbdpi/usbdpi_stream.c hw/top_earlgrey/dv/verilator/chip_sim.core
git commit -m "Fedora 43 / modern GCC+Verilator toolchain compat fixes"
git branch -f ergov2 HEAD
git checkout ergov2
```

## Step 2 - Learn about OpenTitan's Clock Architecture.
OpenTitan Clock Architecture — Earlgrey, from Source

Three distinct levels get called "clock" in this codebase. Conflating them is the most common way to get confused, so keep them separate:

1. Raw async sources — physical oscillators/PLL outputs from the AST, independent of each other
2. Derived clocks — divided/generated versions of a source, still async relative to other sources
3. Gated, per-module clocks — what an individual IP actually receives, after clkmgr applies software/hardware gating

Your 5 constraints map onto these: "5 independent master async clock domains" = level 1, "≥1 generated clock per master" = level 2, "CDC" = boundaries between level-1/level-2 domains, "clock divider, multiple ratios" = the mechanism that produces level 2.

1. Raw sources: the AST and clocks.srcs

The Analog Sensor Top (AST) is the block that actually generates oscillator clocks — real analog circuitry in silicon, modeled behaviorally in hw/top_earlgrey/ip/ast/. Software and RTL both treat it as a black box that hands clkmgr some number of independent async clocks.

The source of truth for how many and at what frequency is hw/top_earlgrey/data/top_earlgrey.hjson:40-45:
srcs: [
  { name: "main", aon: "no",  freq: "100000000" },
  { name: "io",   aon: "no",  freq: "96000000" },
  { name: "usb",  aon: "no",  freq: "48000000" }, 
  { name: "aon",  aon: "yes", freq: "200000", ref: true}
]
Four sources today, not five — this is the exact list you're extending.

Doc: Clock Manager HWIP Technical Specification — confirms clkmgr "accepts raw asynchronous clock sources from the AST." https://opentitan.org/book/hw/ip/clkmgr/

2. clkmgr: sources → derived clocks

clkmgr is the block that turns the raw sources into everything downstream. Two things happen here:

Derived (generated) clocks — top_earlgrey.hjson:54-57:
derived_srcs: [
  { name: "io_div2", aon: "no", div: 2, src: "io", freq: "48000000" },
  { name: "io_div4", aon: "no", div: 4, src: "io", freq: "24000000" }
]
Both of today's derived clocks come off io. This is your model for "≥1 generated clock per master"ds its own derived_srcs entries.

Important nuance from the docs, not obvious from the hjson alone: the derived clock is not treatedrent source. Per the Theory of Operation: "divided clocks are not assumed to be synchronous with its source and is thus treated like another asynchronous branch." So even io → io_div4 inside one master's domain is itself a CDC boundary in this methodology, not a free ratio-clocked relationship. Keep that in mind when you
design domain-internal dividers — you may need synchronizers between a master's raw clock and its etween different masters.

clkmgr.sv (autogenerated, hw/top_earlgrey/ip_autogen/clkmgr/rtl/clkmgr.sv:184-217) instantiates th each derived_srcs entry via prim_clock_div.

3. prim_clock_div: how a divided clock is physically built

hw/ip/prim_generic/rtl/prim_clock_div.sv:7-121 is the real divider primitive:

systemverilog
module prim_clock_div #(
  parameter int unsigned Divisor = 2,
  ...
)
  `ASSERT_INIT(DivEven_A, (Divisor % 2) == 0)

Hard constraint: only even divisors. For Divisor == 2 it's a glitch-free flop+inverter+mux toggle; for larger even divisors it's a counter that flips output every Divisor/2 input cycles, routed through the same anchor mux.
There's no odd-divide support without adding parameters for duty-cycle control — the file's own cople ratios" plan includes anything odd (÷3, ÷5...), that's not free — you'd need to modify orreplace this primitive, not just parameterize it.

This is also a genuine STA-visible generated clock — real designs constrain the divider output with SDC create_generated_clock, which is the literal meaning of your "generated clock" requirement, not just a wire that happens to
toggle slower.

The docs don't have a dedicated page for prim_clock_div itself (verified — hw/ip/prim doesn't cata so the RTL file and its inline comments are the primary source here.

4. Clock groups — a separate axis, don't conflate with domains

top_earlgrey.hjson:81-90 defines six named groups (powerup, trans, infra, secure, peri, timers) coavior — whether/how a module's clock can be turned off, not which physical async domain it belongsto. A single clock domain (e.g. everything on io_div4) has modules spread across multiple groups. This is orthogonal to your "5 master domains" requirement — don't spend design effort here, just know it exists so you don't
misread clock_srcs: {clk_i: "io_div4"} entries as domain assignment when the group name appears ne

Confirmed by Theory of Operation: groups exist for gating/security policy (idle-based hints for crcritical, direct SW control for peripherals) — nothing to do with async domain count.

5. CDC: where it's required, and the toolkit

Every module's clock_srcs entry in top_earlgrey.hjson tells you its domain assignment. A CDC bounde lists two different named clocks, e.g. line 476: clock_srcs: {clk_i: "usb", clk_aon_i: "aon"}(usbdev) — that module straddles the usb and aon domains internally, and its RTL must synchronize between them.

The toolkit, confirmed present in hw/ip/prim/rtl/:
- prim_flop_2sync (via prim_sync_reqack/prim_reg_cdc) — single-bit/small synchronizers
- prim_fifo_async.sv — data crossing via async FIFO
- prim_pulse_sync.sv — single-cycle pulse crossing
- prim_mubi*_sync.sv — multi-bit-encoded (glitch-resistant) signal crossing

Per the Design Methodology page: OpenTitan's own CDC sign-off tooling is explicitly marked TODO/unfinalized upstream — the page states "the tool chosen for this program is not finalized." So there's no official CDC lint/verification flow to lean on yet; you'll be relying on structural correctness (using the right prim + waivers) rather than a sign-off checker. Worth knowing going in, not a gap in your understanding.

The Comportability spec is the source for module-level clocking rules: each IP designates one primary clock for its bus interface, plus an optional clocking list for any additional (potentially async) clocks — this is thepattern behind entries like usbdev's clk_i/clk_aon_i split.

6. Reset domains follow clock domains

Not one of your stated constraints, but unavoidable once you add domain #5: rstmgr generates resets that shadow the clock topology (each clock domain typically gets a matched reset domain, synchronized on deassertion). Adding an async clock domain without a matching reset domain in resets: (hjson, top_earlgrey.hjson:102 onward) will leave that domain's logic without a properly synchronized reset — worth planning alongside the clock work, not after.

How this maps to your spec

| constraint                | Mechanism                                        | File to edit                                 |
| ------------------------- | ------------------------------------------------ | -------------------------------------------- |
| 5 async master domains    | clocks.srcs                                      | top_earlgrey.hjson:40-45                     |
| ≥1 generated clock/master | clocks.derived_srcs                              | top_earlgrey.hjson:54-57                     |
| Multiple divider ratios   | div: field per entry (even numbers only)         | same, prim_clock_div enforces the constraint |
| CDC                       | clock_srcs per module + prim sync toolkit        | per-module .hjson/RTL                        |
| Regeneration              | topgen rebuilds clkmgr/rstmgr RTL from the hjson | topgen docs — don't hand-edit clkmgr.sv      |


## Step 3 - Try to generate the 5th clock 
> NOTE: AST clocks aren't generated by topgen, they're vendored behavioral models with a "closed source generator" header; topgen only owns clkmgr/rstmgr/top_earlgrey.sv downstream of the hjson.

1. Do an edit to `hw/top_earlgrey/data/top_earlgrey.hjson`: in `clocks.srcs` added line `hw/top_earlgrey/data/top_earlgrey.hjson` **(72MHz clock called `exp`)**
2. Every non-aon src must have a *reset domain*. Added `{ name: "por_exp", gen: true, type: "top", parent: "por_aon", clk: "exp" },` node to `resets.nodes` in the hjson.
   > NOTE:
   > **Reset domain**: a logical grouping of logic that shares one reset signal, released together. OpenTitan splits into a test domain (driven by TRSTn) and a core domain (driven by internal POR), and the core domain further branches into specialized reset trees (por, lc, sys, per-module) — which maps directly to the parent.

   > **Why it's needed**: different parts of the chip need to reset independently. E.g. a debug request should be able to reset the core while debug logic itself stays alive — impossible if everything shared one reset. It also lets each clock domain get its own synchronously-released copy of a given reset tree (a reset asserted async but released sync to that domain's clock, to avoid recovery/removal timing violations) — this is exactly why por_io, por_io_div2, por_usb, etc. each exist as separate nodes off the same por_aon parent in the hjson.

   > **POR (Power On Reset)**:  the root reset of the entire device — rst_por_n. If it asserts, everything resets. It's derived from an AST input (aon_pok, power-good), synchronized (3-stage) and stretched (32-cycle counter by default) to ride out voltage-ramp glitches before releasing.

   > **Cascading**: resets form a chain: rst_por_n -> rst_sys_n/rst_lc_n -> rst_module_n. so a parent asserting forces all children to assert too. children can never be *un-reset* while their parent is reset. That's exactly what parent: "por_aon" means for your new por_exp node.

   > "**por_aon**" means: when the chip-wide power-on reset fires, exp's domain resets too, released synchronously to the exp clock

3. **Run topgen**
   > `pip3 install --user -r python-requirements.txt --require-hashes` python dependencies

   > **NOTE** fedora requires `libxml2-devel, libxslt-devel` - install with `dnf` before running pip install.

   > **NOTE** this version has `libcst` that requires an older version of Python==3.12. install it and run the pip install in a venv if you have a later version or py. **Remember to activate the venv before running topgen**

   > `cd hw/top_earlgrey && ../../util/topgen.py -t data/top_earlgrey.hjson -o . -v` - run topgen


## topgen error log
**ERROR 1**
```
ERROR:  clkmgr mismatched number of reset ports and nets
ERROR:  clkmgr mismatched number of clock ports and nets
ERROR: module clock/reset checking failed
INFO: Checking clock/resets for xbar main
INFO: xbar main resets are ['rst_main_ni', 'rst_fixed_ni', 'rst_spi_host0_ni', 'rst_spi_host1_ni', 'rst_usb_ni']
ERROR: xbar clock/reset checking failed
Error occured while validating top.hjson
```
**FIX 1**
1. Add an `lc_exp` reset node — clkmgr's per-domain reset ports are wired to the `lc_*` tree, not `por_*` directly In resets.nodes (top_earlgrey.hjson:139-164), add
`{ name: "lc_exp", gen: true, type: "top", parent: "lc_src", clk: "exp" },`
2. Extend `clkmgr_aon`'s module entry (`top_earlgrey.hjson:416-445`) — add one more `clk_*_i and rst_*_ni` pair, matching the existing pattern for each of the 4 current src:
   In clock_srcs (after clk_aon_i, line 432-435):
```clk_exp_i: {
  group: "ast",
  clock: "exp"
}
```
3. In `reset_connections` (after `rst_usb_ni: "lc_usb"`, line 444):
   `rst_exp_ni: "lc_exp",`

**ERROR 2**
```
INFO: Checking clock/resets for rstmgr_aon
INFO:  rstmgr resets are ['rst_ni', 'rst_por_ni']
INFO: Checking clock/resets for clkmgr_aon
INFO:  clkmgr resets are ['rst_ni', 'rst_root_ni', 'rst_main_ni', 'rst_io_ni', 'rst_usb_ni', 'rst_aon_ni', 'rst_exp_ni', 'rst_io_div2_ni', 'rst_io_div4_ni', 'rst_root_main_ni', 'rst_root_io_ni', 'rst_root_io_div2_ni', 'rst_root_io_div4_ni', 'rst_root_usb_ni', 'rst_root_exp_ni']
ERROR:  clkmgr mismatched number of reset ports and nets
ERROR: module clock/reset checking failed
INFO: Checking clock/resets for xbar main
INFO: xbar main resets are ['rst_main_ni', 'rst_fixed_ni', 'rst_spi_host0_ni', 'rst_spi_host1_ni', 'rst_usb_ni']
ERROR: xbar clock/reset checking failed
Error occured while validating top.hjson
```
**FIX 2**
**(Claude)**
```
Fix 1 — clkmgr_aon reset ports (line ~417): clkmgr generates one rst_root_<domain>_ni port per clock domain (for every domain except aon). We'd added por_exp/lc_exp reset nodes and rst_exp_ni, but missed the rst_root_exp_ni variant. Added:
rst_root_exp_ni: "por_exp",

Fix 2 — rstmgr_aon clock ports (line ~392): rstmgr needs one clk_<domain>_i input per domain, to synchronously release that domain's reset. exp was missing from its clock_srcs dict. Added:
clk_exp_i: "exp"

The "xbar" error wasn't real: check_clocks_resets() in validate.py uses one shared error counter across the entire function. When rstmgr's check failed, it incremented error and broke out of the module loop — but error stayed nonzero. The xbar loop right after does if error: log.error("xbar clock/reset checking failed"), which fires just because the counter was already >0 from rstmgr, not because anything was actually wrong with the xbar's own 5 reset connections (which I'd already confirmed were correct by reading top_earlgrey.hjson:1169-1183). Once rstmgr was actually fixed, error was 0 by the time that loop ran, so the message never appeared — confirming that read was correct.

Net effect: your 5th clock domain (exp) is now fully consistent across clocks.srcs, resets.nodes (por_exp, lc_exp), and every autogenerated manager (clkmgr, rstmgr) that needs to know about it.
```

## Check diff of `top_earlgrey.v` to see if it worked!
`git diff -- hw/top_earlgrey/rtl/autogen/top_earlgrey.sv`
Success! We've told the digital top "there's a 5th clock coming in" and had the tools automatically build all the plumbing for it — a new input port, its own gated/enable logic, and its own reset tree — without touching any generated code by hand. Nothing physically produces that clock yet; it's a wire waiting for a signal. Next step is building the actual oscillator (in ast.sv) and connecting it to that wire.

**Next steps**:
4. hw/top_earlgrey/ip/ast/rtl/ — add a new behavioral oscillator module, cloned from usb_clk.sv (48 MHz gateable pattern) or aon_clk.sv (free-running pattern) depending on whether exp should be gateable. Give it its own <name>_osc.sv submodule the way usb_clk.sv:105 instantiates usb_osc.
5. hw/top_earlgrey/ip/ast/rtl/ast.sv — instantiate the new module (mirror the u_usb_clk/u_sys_clk/u_io_clk/u_aon_clk instances around lines 374-509), and add matching clk_src_exp_o/clk_src_exp_val_o/clk_src_exp_en_i ports to ast.sv's own port list.
6. hw/top_earlgrey/rtl/chip_earlgrey_verilator.sv — this is the one chip-level wrapper that's hand-maintained, not autogenerated (confirmed: chip_earlgrey_asic.sv/cw310/cw340 live under rtl/autogen/, verilator's does not). Wire u_ast's new clk_src_exp_o to the new clk_exp_i port on top_earlgrey.sv from step 3.
7. Back in top_earlgrey.hjson — add a derived_srcs entry sourced from exp with an even divisor (prim_clock_div's ASSERT_INIT(DivEven_A, (Divisor % 2) == 0) forbids odd ratios). Re-run topgen. This satisfies "≥1 generated clock per master" for domain 5 and gets you a real prim_clock_div instance for free.
8. Deferred, tied to trimming: pointing an actual peripheral's clock_srcs at exp/exp_div* is what creates the real CDC boundary. You said hold trimming — so hold this step too; steps 1-7 stand on their own and don't require knowing which IP lands on domain 5 yet.


## note before tying ast oscillator to the modules
`Flag: ast.sv itself carries the same AUTO-GENERATED... PLEASE DO NOT HAND-EDIT (closed source generator) header as sys_clk.sv/ast_clks_byp.sv. We're deliberately overriding that — there's no alternative since we don't have lowRISC's internal generator — but it's worth being conscious that this is a deviation from upstream convention, same as sys_clk.sv was.`

**EDITS MADE**:
```
1. hw/top_earlgrey/ip/ast/rtl/ast_pkg.sv:138-143 — add a field to the bypass-clock struct (needed because exp_clk.sv/exp_osc.sv reference clk_exp_ext_i under AST_BYPASS_CLK, sourced from this struct):
systemverilog
typedef struct packed {
  logic     usb;
  logic     sys;
  logic     io;
  logic     aon;
  logic     exp;
} clks_osc_byp_t;

2. ast.sv port list, right after the USB block (after line 98, before the // adc interface comment at line 100) — mirror the "system source clock" block at lines 76-80:
systemverilog
  // expansion source clock
  input clk_src_exp_en_i,                     // EXP Source Clock Enable
  input prim_mubi_pkg::mubi4_t clk_src_exp_jen_i,  // EXP Source Clock Jitter Enable
  output logic clk_src_exp_o,                 // EXP Source Clock
  output logic clk_src_exp_val_o,             // EXP Source Clock Valid

3. ast.sv oscillator section — the safest way to do this: select lines 355-387 (the whole "System Clock (Always ON)" block, header comment through the closing );), copy it, paste the copy right after line 387 (before the // USB Clock comment at 390), then rename within just the pasted copy: sys→exp, Sys→Exp, SYS→EXP. Copying verbatim rather than retyping avoids missing a wire I might paraphrase wrong (e.g. the clk_src_sys_jen mubi qualifier). End result should look like:
systemverilog
///////////////////////////////////////
// Expansion Clock (Always ON)
///////////////////////////////////////
logic rst_exp_clk_n, clk_exp_pd_n;
logic clk_exp_en, clk_osc_exp, clk_osc_exp_val;
prim_mubi_pkg::mubi4_t clk_src_exp_jen;

assign rst_exp_clk_n = vcmain_pok_por && vcc_pok;
assign clk_exp_pd_n  = scan_mode || !deep_sleep;

logic exp_osc_cal;

assign clk_exp_en = clk_src_exp_en_i;

`ifdef AST_BYPASS_CLK
logic clk_exp_ext;
assign clk_exp_ext = clk_osc_byp_i.exp;
`endif

exp_clk u_exp_clk (
  .clk_src_exp_jen_i ( prim_mubi_pkg::mubi4_test_true_loose(clk_src_exp_jen) ),
  .clk_src_exp_en_i ( clk_exp_en ),
  .clk_exp_pd_ni ( clk_exp_pd_n ),
  .rst_exp_clk_ni ( rst_exp_clk_n ),
  .vcore_pok_h_i ( vcaon_pok_h ),
  .scan_mode_i ( scan_mode ),
  .exp_osc_cal_i ( exp_osc_cal ),
`ifdef AST_BYPASS_CLK
  .clk_exp_ext_i ( clk_exp_ext ),
`endif
  .clk_src_exp_o ( clk_osc_exp ),
  .clk_src_exp_val_o ( clk_osc_exp_val )
);
(Note: exp_osc_cal is declared here but never driven — that matches the stock sys_io_osc_cal pattern, which is also just tied off/unused in this simulation model; leave it as-is for consistency.)

4. ast.sv, after the ast_clks_byp instantiation closes (after line 547) — since we're bypassing ast_clks_byp for exp, add its own direct output buffer, mirroring the "System source clock buffer" block at lines 549-556:
systemverilog
// Expansion source clock buffer
////////////////////////////////////////
prim_clock_buf #(
  .NoFpgaBuf ( 1'b1 )
) u_clk_src_exp_buf (
  .clk_i ( clk_osc_exp ),
  .clk_o ( clk_src_exp_o )
);

assign clk_src_exp_val_o = clk_osc_exp_val;

After all four, ast.sv will have real clk_src_exp_o/clk_src_exp_val_o/clk_src_exp_en_i ports matching the plan from a few turns ago. Next step after this is wiring u_ast's clk_src_exp_o to top_earlgrey.sv's clk_exp_i in chip_earlgrey_verilator.sv — but do these four first and let me know when they're in so we can sanity-check before moving on.
```

## Tying the oscillator to the clock
```ast.sv wiring (previous step)

Added exp as a full 5th clock source at the AST (Analog Sensor Top) level, mirroring the existing sys domain's pattern in 4 places:
1. ast_pkg.sv: added logic exp; to the clks_osc_byp_t struct — the type used to feed external bypass clocks into AST under AST_BYPASS_CLK (the Verilator/FPGA build mode).
2. ast.sv port list: added clk_src_exp_en_i, clk_src_exp_jen_i (jitter enable), clk_src_exp_o, clk_src_exp_val_o — same shape as the existing sys ports.
3. ast.sv oscillator instantiation: added a full "Expansion Clock" block instantiating exp_clk (the module we wrote earlier), with its own power-down/enable/reset logic, matching sys's block exactly.
4. ast.sv output buffering: added a dedicated prim_clock_buf stage producing the final clk_src_exp_o/clk_src_exp_val_o, deliberately not routed through ast_clks_byp (the shared 4-domain-only DFT/OTP-bootstrap bypass-mux module) — a scoped decision to avoid touching a second closed-source-generated file for functionality your benchmark doesn't need.

chip_earlgrey_verilator.sv wiring (this step)

This is the Verilator-specific chip top, and it revealed that sys/io/usb don't actually route through AST's real clock outputs here — they're all tied straight to the single external clk_i testbench pin, with only aon genuinely derived (via a prim_clock_div ÷4). To follow that established pattern rather than invent a new one:

1. Added a second real divider, u_exp_div (÷6, chosen distinct from aon's ÷4), producing clk_exp from clk_i.
2. Extended the clks_osc_byp struct literal with exp: clk_exp, so u_ast's exp oscillator (under AST_BYPASS_CLK) has a real external clock to gate.
3. Wired u_ast's new clk_src_exp_en_i/clk_src_exp_jen_i ports (tied to 1'b1 and jen respectively, since — unlike sys/io/usb — exp isn't part of pwrmgr's power-up sequencing, so there's no pwrmgr-provided enable signal to reuse). clk_src_exp_o is left unconnected and clk_src_exp_val_o sinks to a declared-unused wire, matching how sys/io/usb's AST outputs are already bypassed for the actual top-level connection in this file.
4. Connected top_earlgrey's new clk_exp_i port directly to the divided clk_exp wire — same pattern as clk_main_i/clk_io_i/clk_usb_i/clk_aon_i.

Caveat carried over from earlier: clk_exp is a rational divisor of clk_i, not a truly independent asynchronous source — that's a property of this single-clock-input Verilator testbench, not the RTL's declared topology (which is genuinely 5 independent domains, and is what your Yosys/OpenSTA benchmark flow will actually see).

Next: build/lint the Verilator target to confirm nothing broke.
```

**Issue**: **VERILATOR BUILD FAILED**
```
Summary

What broke and why: pwrmgr — unlike clkmgr/rstmgr — isn't actually topgen-templated. Its RTL (pwrmgr.sv, pwrmgr_pkg.sv, pwrmgr_fsm.sv) are plain .sv files in hw/ip_templates/pwrmgr/, confirmed byte-identical to their copies in hw/top_earlgrey/ip_autogen/pwrmgr/ — topgen just copies them verbatim, no Mako substitution. So pwrmgr's low-power sequencing logic only ever knew about {main, io, usb} (checked its structs — notably no aon field either, since aon is always-on and never gated). clkmgr.sv, which is genuinely templated, now generates a per-domain low-power handshake for every gateable (aon: "no") clock source uniformly, including exp — so it expected pwr_i.exp_ip_clk_en / pwr_o.exp_status, fields pwrmgr's hand-written package never had.

What I changed, all in hw/ip_templates/pwrmgr/rtl/ (the real source — editing the ip_autogen copies directly would've been silently overwritten by the next topgen run, since topgen just re-copies these files):

1. pwrmgr_pkg.sv: added logic exp_ip_clk_en; to pwr_clk_req_t (pwrmgr→clkmgr) and logic exp_status; to pwr_clk_rsp_t (clkmgr→pwrmgr) — same shape as the existing main/io/usb fields.
2. pwrmgr_fsm.sv: added assign ips_clk_en_o.exp_ip_clk_en = 1'b1; right next to the existing main_ip_clk_en/io_ip_clk_en assigns — permanently requesting exp's clock enabled, so pwrmgr never gates it during low-power sequencing. This is consistent with the earlier decision in chip_earlgrey_verilator.sv (AST's clk_src_exp_en_i also tied to constant 1'b1) — exp simply isn't part of the power-sequencing story.

One subtlety worth knowing: pwrmgr's FSM has a generic "all clocks acknowledged" completion check that bitwise-ANDs the entire ips_clk_en_o/clk_en_status_i structs together (&((ips_clk_en_o & clk_en_status_i) | ~ips_clk_en_o)). Since exp_ip_clk_en is now permanently 1, and clkmgr will assert exp_status once its real AST-driven clock is actually toggling, that term naturally resolves to 1 and never blocks the completion check — this isn't a stub that silently breaks something else, it genuinely satisfies the handshake.

I copied both fixed files into ip_autogen/pwrmgr/rtl/ directly so you don't need to re-run topgen before rebuilding — but a future topgen run will pick up the same fix automatically since it just re-copies these source files.

Next: re-run the Verilator build to confirm this actually resolves the compile error.
```

## 5th master clockk added, divided(generated) clocks added for each master. clock structure as of now:
```
main  (100 MHz) ──┬── main_div2  (50 MHz, ÷2)
      [root]      └── main_div10 (10 MHz, ÷10)

io    ( 96 MHz) ──┬── io_div2 (48 MHz, ÷2)
      [root]      └── io_div4 (24 MHz, ÷4)

usb   (48 MHz) ──── usb_div4 (12 MHz, ÷4)
      [root]

aon   (200 kHz) ──── X (no derived clocks — topgen structurally forbids deriving from an aon-marked source; bypasses clkmgr entirely)
      [root, free-running, no gating]       

exp   (72 MHz) ──┬── exp_div2 (36 MHz, ÷2)
      [root]     └── exp_div8 (9 MHz, ÷8)
```

| Clock | Freq | Master | Ratio | Wired through clkmgr/rstmgr | Real peripheral consumer | Survives synthesis | Real CDC boundary |
|---|---|---|---|---|---|---|---|
| main | 100 MHz | root | — | yes | yes (rv_core_ibex, aes, hmac, ...) | yes | yes |
| io | 96 MHz | root | — | yes | yes (spi_host0, ...) | yes | yes |
| usb | 48 MHz | root | — | yes | yes (usbdev) | yes | yes |
| aon | 200 kHz | root | — | yes (unmanaged) | yes (pwm_aon, adc_ctrl_aon, aon_timer_aon, wake-detect paths, rstmgr/pwrmgr) | yes | yes |
| io_div2 | 48 MHz | io | ÷2 | yes | yes (spi_host1) | yes | yes |
| io_div4 | 24 MHz | io | ÷4 | yes | yes (uart0-3, gpio, i2c0-2, pattgen, most peripherals) | yes | yes |
| exp | 72 MHz | root | — | yes | no | at risk — no downstream flip-flop is clocked by it yet | no — declared but no crossing exists |
| main_div2 | 50 MHz | main | ÷2 | yes | no | at risk | no |
| main_div10 | 10 MHz | main | ÷10 | yes | no | at risk | no |
| usb_div4 | 12 MHz | usb | ÷4 | yes | no | at risk | no |
| exp_div2 | 36 MHz | exp | ÷2 | yes | no | at risk | no |
| exp_div8 | 9 MHz | exp | ÷8 | yes | no | at risk | no |

```
Note on "at risk": the divider hardware itself (prim_clock_div counter, clkmgr's enable/status flops) is real logic clocked by the source clock, and clkmgr's own status/CSR tracking taps its enable/valid signals — that much will likely survive synthesis regardless. What's genuinely missing is any flip-flop actually clocked by these 5 new derived clocks (or by exp itself) — without one, there's no real clock-tree leaf and no CDC synchronizer for a synthesis/STA tool to report on. That's the gap the next step (assigning real consumers) closes.
```

## Adding peripherals to consume all the clocks, so that they survive synth and also have CDC boundaries.

This is a meaningfully different kind of work than what we've done so far — everything up to now has been topgen-managed plumbing; this is genuinely new functional RTL design (real logic that needs to work correctly and contain controllable timing challenges). Before writing anything, here's the plan and one real decision point.

Why I'd avoid repointing stock peripherals onto the new domains: existing IP like usbdev/spi_host/i2c was designed and verified against its current clock assignment — its internal CDC synchronizers, timing assumptions, and DV coverage all assume usb/io_div4/etc. Forcibly reassigning one to exp_div2 risks silently breaking something subtle (a synchronizer that assumed a specific frequency ratio, a DV testbench assumption) without giving us any control over what kind of timing challenge results — it's a gamble, not a designed benchmark case.

Recommendation: build 1-2 small, purpose-built custom modules instead — a "benchmark harness" block, clocked by the domains that need consumers, containing three deliberate ingredients:
1. Real CDC crossings (functionally correct, using prim_flop_2sync/prim_fifo_async) between an existing domain (e.g. io_div4) and the new ones (exp, exp_div2, exp_div8, main_div2, main_div10, usb_div4) — this is what makes the crossing genuine and gives every new derived clock a real consumer (instantiate it multiple times / with multiple sub-blocks per clock to satisfy "multiple peripherals per clock").

2. A deliberately tight combinational path between two registers on the same new clock (e.g., an unpipelined multiply-accumulate chain) sized so it just barely violates setup at the target frequency — a controllable, known setup violation for the optimizer to find and fix (e.g. via pipelining or retiming).

3. A deliberately short register-to-register path (single gate, or a path exploiting the divided clock's insertion-delay skew from its source, which — per the docs we found earlier — OpenTitan itself treats as a genuine async branch) — a controllable, known hold violation.

This gives us full control over what violations exist (useful for a benchmark, where "unknown, maybe-broken stock IP timing" is not useful), keeps the rest of the chip's verified functional correctness untouched, and directly serves the stated end goal.

**Decision:**

Three module types:

1. bench_cdc_bridge — an async-FIFO-based CDC crossing (prim_fifo_async), taking data from io_div4 (already a populated, safe source domain) and forwarding it into one of the needy clocks. This is the mandatory piece — it's what makes the crossing a real, functionally-correct CDC boundary.
2. bench_setup_gen — a deliberately unpipelined arithmetic chain (multi-stage multiply-accumulate with no retiming) between two same-domain registers, sized to just barely violate setup at the target frequency — a controllable, known setup violation.
3. bench_hold_gen — a near-zero-logic register-to-register path, placed so one flop sits on a root clock and the very next sits on its derived clock with no synchronizer between them. Per the docs we found earlier ("divided clocks are treated as another async branch"), an unsynchronized root→derived crossing is exactly the kind of thing real CDC/timing tools flag — deliberately used here as a known hold/CDC violation, not an accidental bug.

Shape decision: I'll give each module the same minimal TL-UL peripheral shape as gpio (a couple of registers, base_addr, standard clock_srcs/reset_connections) rather than inventing a bus-free IP shape — that's the exact pattern we've already proven end-to-end through topgen/reggen/Verilator, so it avoids opening up new, unverified schema territory on top of everything else in flight.

Coverage: every clock still needing a real consumer (exp, exp_div2, exp_div8, main_div2, main_div10, usb_div4) gets one instance of each of the 3 modules — 3 consumers per clock, one real CDC boundary, and both a setup and a hold challenge apiece. 18 module instances total across 3 new IP types.

Sequencing: rather than writing and wiring all 18 at once (high odds of compounding topgen/reggen errors, same as we saw scaling from 1 to 5 derived clocks), I'll build bench_cdc_bridge first, wire it to just exp alone, and get it through topgen + a Verilator build clean — then scale the proven pattern out to the rest. Starting on bench_cdc_bridge now unless you want to adjust anything above first.

# VERY IMPORTANT HIGHLY RELEVANT CONVO WITH CLAUDE - MUST MUST MUST READ
> question - you said bench_setup_gen will BARELY violate timing at "target frequency". i will be modifying frequencies later when i use this benchmark on my ai system. will this fact still hold? in fact, what all can break (otehr than timing violations) when i do change the frequency?

Good catch — no, it won't hold, and there's a broader list of things that would break too.

Why "barely violates" doesn't survive a frequency change: setup slack = period − (combinational delay + flop overhead). I'd size bench_setup_gen's logic-chain depth to marginally violate at one specific SDC period. That depth is a fixed structural property of the RTL — it doesn't move when you later declare a different create_clock -period. Lower the frequency and the "violation" disappears (becomes trivially met, useless as a challenge); raise it and the violation gets worse in an uncontrolled way, and — more importantly — it's no longer just that one path: every other real path in the design could start failing too, not just my deliberately-tuned ones, since none of stock Earlgrey's logic (which we've never actually run through Yosys — only Verilator sim and topgen validation, both frequency-invariant) was verified against arbitrary frequency targets. A big enough frequency bump turns this from "3 known controllable violations" into "unknown number of violations scattered across the whole netlist."

Fix: don't hardcode a margin — parameterize the chain depth (parameter int NumStages) so whatever generates your benchmark variants for the AI system picks depth per target frequency, rather than me baking in a single frequency's assumption. I'll build it this way from the start.

Other things that break or silently diverge on a frequency change, beyond timing violations:

- Verilator/AST sim-model constants are hardcoded and won't auto-track. exp_osc.sv's CalExpClkPeriod = 13889 (ps) and its jitter formula are fixed values calibrated to 72 MHz. If you change the SDC frequency for STA purposes but don't also update this file, Verilator simulation and OpenSTA analysis will silently describe two different frequencies for the same clock — not a synthesis break, but a real functional/sim-fidelity divergence if you ever care about simulation matching your STA target.
- bench_cdc_bridge's async FIFO depth is sized against an assumed worst-case rate mismatch between its two clock domains. If a frequency change shifts the ratio between two domains a lot (not just one domain's absolute value), the FIFO could underflow/overflow — CDC synchronizer correctness (metastability resolution) stays fine regardless of frequency, but throughput/backpressure assumptions don't.
- Reset stretch counters are cycle-counted, not time-counted (e.g. rstmgr's 32-cycle POR stretch) — on a much slower clock this just means longer wall-clock time before reset releases, not a correctness break, but worth knowing if you're watching simulation wall-time.

What stays robust automatically: SDC generated-clock relationships (create_generated_clock -divide_by N) and set_clock_groups -asynchronous declarations are ratio/name-based, not tied to a specific period value — those don't need to be touched when you sweep the root create_clock period.


> but that's the point: if my benchamrk has a whole lot of timing violations everywhere, it will pose a larger challenge to the AI system that is supposed to fix those violations. after the optimization run, there will be an equivalence check using EQY to verify that logic didnt break. is this reasoning correct? if not where does this prompt's reasoning line fail?

Partially correct — EQY is exactly the right tool for what it does, but the reasoning has a real gap.

What holds: EQY (Yosys formal equivalence checking) correctly proves the post-optimization netlist is functionally identical to the pre-optimization reference, for exactly the kinds of transformations a timing-closure engine applies — retiming, buffering, gate resizing, logic restructuring. That part of your reasoning is sound and is genuinely the right check to run after the loop.

Where it fails: you're conflating quantity/severity of violations with benchmark quality. EQY only answers "did the fix stay functionally correct" — it says nothing about two things that actually matter for a good benchmark:

1. Whether the violations are legitimately closable by timing-closure techniques at all. Real timing closure (retiming, pipelining, buffer insertion, useful skew, cell resizing) has limits — it can't fix a case where the required frequency is faster than a single carry chain or multiply tree can physically settle without adding real pipeline latency (which changes cycle-accurate behavior — may or may not stay EQY-equivalent depending on interface protocol assumptions). Push frequency far enough via blind scaling and you'll create instances that aren't "harder," they're unsolvable without algorithmic redesign — a categorically different problem than timing closure, and it silently mixes into your benchmark without you knowing which paths crossed that line, since this design has never actually been through Yosys/OpenSTA to characterize its real critical paths.
2. Ground truth and reproducibility. A benchmark is only useful if you can characterize what's being tested — "N known setup violations of type X at these locations, M known hold violations, one known CDC gap" — so you can score whether the optimizer actually solved the designed challenges (vs. improved WNS/TNS by luck on unrelated incidental paths) and compare across optimizer versions on a fixed, known difficulty. Violations that emerge unpredictably from scaling frequency across the whole never-synthesized design have no such catalog — you lose the ability to say what was actually fixed, which undermines the benchmark as an evaluation tool even though EQY confirms the end state is functionally fine.

There's also a subtler point for a ShinkaEvolve-style loop specifically: an unbounded, chaotic violation landscape can make for a worse optimization landscape even when it's harder in a raw sense — if WNS/TNS swings wildly and unpredictably as candidates mutate, the fitness signal gets noisy and less informative, which hurts the search more than it stresses it usefully.

Practical implication: it's fine — good, even — to let frequency scaling add extra emergent violations on top of the deliberately engineered ones once you start sweeping frequency later; more stress is a reasonable thing to want. But the 3 modules should stay as your known, characterized core (documented location, type, and intended fix), and it's worth deciding your frequency sweep range with some sense of where things tip from "harder closure problem" into "physically requires redesign" — otherwise you risk the benchmark occasionally being unsolvable rather than just difficult, which EQY won't catch or warn you about (it'll happily confirm a still-broken-timing netlist is functionally correct).

> so is it possible to define the limit up to which i can safely increase frequencies such that the violations they cause remain "legitimately closable", a limit that is large enough to produce severe and numerous viollations that thooughly test my optimizer's capability, and also is it possible to ensure that i can have an account of the number of known violations on the benchmark's side, that may be compared with the o/p of the optimizer? basically my target is a solvable yet highly challenging benchmark that supports high frequency of optimization, and whose parameters are known documented and reproducable.

Yes to both, but the honest answer to "what's the exact frequency ceiling" is: I can't give you a real number without running actual synthesis (we've never run Yosys on this design — everything so far has been topgen validation and Verilator sim, both frequency-invariant). What I can do is make the ceiling knowable and the closability provable by construction, rather than guessed.

Making "legitimately closable" a provable property, not a guess

The real constraint on retiming/pipelining as a closure technique: for a pure feedforward combinational chain with no functional-latency contract, you can always close any target period by inserting enough pipeline stages — the only true floor is a single gate's intrinsic delay, which is far below anything a realistic benchmark frequency would hit. So instead of picking a frequency number and hoping it stays "closable," I'll design bench_setup_gen's chain to be:
- Purely feedforward (no combinational loops, no protocol-fixed latency),
- Interfaced via ready/valid handshaking, not a fixed-cycle contract, so an optimizer inserting extra pipeline stages doesn't violate any timing contract the rest of the design assumes,
- Structured with explicit natural pipeline-insertion points (parameterized stage count), so a correct retiming solution provably exists for any target period you throw at it.

With that construction, those specific modules have no real "too high" frequency — you can push them arbitrarily hard and the challenge scales in difficulty (more stages needed) without ever crossing into "impossible." The genuinely open question becomes stock Earlgrey peripherals — TL-UL bus timing, register-access assumptions, etc. weren't designed latency-tolerant, so pushing global frequency very high risks hitting real protocol-fixed limits there, not just longer combinational paths. My recommendation: keep the deliberately-injected modules as your primary, provably-scalable difficulty knob, and treat any frequency high enough to threaten stock peripherals as a separate, riskier regime you sweep into only once you've confirmed (via one real synthesis+STA baseline) what stock critical paths look like.

Getting a known, documented, reproducible violation catalog — two layers

1. A baseline OpenSTA report is your ground truth, for free, at any frequency. Same RTL + same SDC + same target period → deterministic, reproducible timing report. Run this once before any optimizer touches the design at whatever frequency you're testing, save it as the reference. Post-optimization, diff the new OpenSTA report (plus EQY for functional correctness) against that baseline — this covers every violation, deliberate or emergent, with zero extra bookkeeping infrastructure since the tool generates it directly.
2. A hand-authored manifest for the deliberately-injected modules specifically (YAML/JSON: module, instance, clock domain, violation type, expected closure technique, parameterized stage count needed at a given target period) — this documents the designed core of the benchmark in human-readable form, separate from whatever else the baseline STA report finds. Lets you score "did the optimizer solve the challenges I actually built in" distinctly from "did it also opportunistically clean up incidental stock-design slack."

Concretely: I'd build bench_setup_gen/bench_hold_gen as parameterized generators (stage count, target period as module parameters) rather than fixed RTL, plus the manifest — that's what makes "high frequency of optimization runs" practical, since regenerating a new difficulty level is a parameter change, not a redesign, and each variant's baseline STA report is trivially reproducible.


## BE SURE TO READ THIS!!!!!!
> **additionally, another relevant parameter for my optimizer would be "how much can you optimize timing, even if you cant achieve timing closure". so would it be prudent (answer thgoughtfully and critically - dont just agree blindly), to have a version of this benchmark to which ill make arbitrary freq scalings, that cause arbitrary violations that may not be "solvable" but may be "improvable" through traditional optimization techniques without algo. redesign, that would also serve as a useful stress test to my model?** 


Yes, prudent — but with real caveats, not a blank endorsement. Walking through why it's a good idea, then what could go wrong if built carelessly.

Why it's genuinely valuable, not just "more stress": "can it fully close" and "how gracefully does it degrade when it can't" are different capabilities, and real timing-closure work is asked to do the second constantly — designs frequently ship with accepted, characterized slack because full closure wasn't achievable in the time/technique budget. A benchmark that only ever tests binary pass/fail misses that entirely. It's also a genuinely good adversarial check: since you know a-priori this variant can't be fully closed, if your optimizer ever reports zero violations on it, that's a direct signal something's wrong — either it's gaming the timing metric, or (more dangerously, for a ShinkaEvolve-style mutating loop) it found a way to satisfy the timing score by breaking functionality, which EQY should then catch. So this variant is also a useful trap for reward-hacking, not just a stress test.

Where it needs real design discipline, not just cranking a frequency knob:

1. Keep it a separate metric axis, don't blend it into the main score. "Did you close timing" (binary, clean ground truth from the provably-pipelinable modules) and "how much did you improve an infeasible case" (continuous, no clean target) answer different questions. Mixing them into one aggregate number muddies both — you'd lose the ability to say cleanly "the optimizer can/can't do full closure" and "the optimizer degrades well/badly under infeasibility."
2. Score by relative improvement, not absolute target. Without a provable closure point, there's no "expected" answer — score as % WNS/TNS reduction versus an untouched baseline (or versus best-achieved-so-far across runs/optimizer versions), which is a legitimate way to rank optimizer quality without knowing the true achievable optimum.
3. EQY becomes more load-bearing here, not less — make it a hard gate, not a penalty. In the solvable variant, a clean target limits how an optimizer can "cheat." Here, with no clean target and partial credit for any improvement, the incentive to find a degenerate-but-technically-still-passes-in-simulation shortcut is higher. Any candidate that fails EQY should be rejected outright, not scored as "improved but penalized." One reassurance worth noting: EQY operates on the untimed logic model, so it stays fully applicable regardless of how far past physically-realistic the timing constraint is pushed — that safety net doesn't degrade even in an absurd-frequency regime.
4. "Arbitrary" shouldn't mean literally unbounded — calibrate empirically once you have real synthesis data. Push frequency far enough and you hit a regime where everything fails by such enormous margins that any optimizer's output is statistically indistinguishable from any other's — at that point you're not stress-testing optimization skill anymore, you're testing "does it crash or time out," which is a different, much less interesting thing to measure and actually reduces the signal quality you're after. Worth finding the "meaningfully differentiated improvement still possible" band empirically after your first real synthesis+STA baseline, rather than committing to a specific multiplier now.
5. Decide deliberately whether this variant includes the stock peripherals or stays scoped to your engineered modules pushed harder. Stock TL-UL/register-access logic has protocol-fixed timing assumptions elsewhere in the software/verification stack — pushing those into extreme violation territory risks the failure being "the bus protocol contract is now nonsensical" rather than "a genuinely improvable timing path," which is a less useful kind of stress.

> **Net: yes, build it, but as a clearly-labeled second benchmark variant with its own relative-scoring methodology and a mandatory EQY gate — not as a harder setting on the same knob as the solvable benchmark.**

## Clock structure — complete, as of 2026-09-03 (post exp2)

### 6 master clock domains

| Master | Freq | aon | Notes |
|---|---|---|---|
| `main` | 100 MHz | no | stock |
| `io` | 96 MHz | no | stock |
| `usb` | 48 MHz | no | stock |
| `aon` | 200 kHz | **yes** | stock, free-running, bypasses clkmgr entirely — see exemption note below |
| `exp` | 72 MHz | no | added — real AST oscillator (`exp_clk.sv`/`exp_osc.sv`), full chip wiring |
| `exp2` | 60 MHz | no | added — real AST oscillator (`exp2_clk.sv`/`exp2_osc.sv`), full chip wiring |

### 9 derived (generated) clocks

| Derived clock | Freq | Ratio | Source |
|---|---|---|---|
| `io_div2` | 48 MHz | ÷2 | `io` |
| `io_div4` | 24 MHz | ÷4 | `io` |
| `main_div2` | 50 MHz | ÷2 | `main` |
| `main_div10` | 10 MHz | ÷10 | `main` |
| `usb_div4` | 12 MHz | ÷4 | `usb` |
| `exp_div2` | 36 MHz | ÷2 | `exp` |
| `exp_div8` | 9 MHz | ÷8 | `exp` |
| `exp2_div2` | 30 MHz | ÷2 | `exp2` |
| `exp2_div6` | 10 MHz | ÷6 | `exp2` |

Distinct ratios present: {2, 4, 6, 8, 10} — 5 distinct ratios, satisfying "multiple ratios."

### `aon`'s exemption

`aon` cannot be the `src` of a `derived_srcs` entry — `util/topgen/clocks.py:320-325` throws `KeyError` if you try, since `aon` bypasses clkmgr by design and topgen's derived-clock machinery was never built to hang anything off it. Deliberately left as-is rather than replaced (it's load-bearing: rstmgr's POR root, pwrmgr's hand-written low-power FSM, several wake-detect peripherals). `exp2` was added as a genuine 6th master instead of forcing `aon` to fit the pattern.

### Reset topology

Every clock (root or derived) gets a `por_<name>` node (parent: `por_aon`) and an `lc_<name>` node (parent: `lc_src`) in `resets.nodes`. `clkmgr_aon` needs both a plain `rst_<name>_ni` (lc-based) and a `rst_root_<name>_ni` (por-based) entry per clock. `rstmgr_aon` needs one `clk_<name>_i` input per clock referenced by any reset node's `clk:` field — driven by `resets.get_clocks()`, independent of what clkmgr needs.

### 32 `ergo_*` benchmark consumer instances

Ground truth lives in `hw/top_earlgrey/data/ergo_manifest.yaml` (regenerate via `python3 util/ergo_manifest.py -t hw/top_earlgrey/data/top_earlgrey.hjson -o hw/top_earlgrey/data/ergo_manifest.yaml` after any module-list or RTL change). Every needy clock (every domain except `main`/`io`/`usb`/`aon`, which already had stock consumers) has:

- 1× `ergo_cdc_bridge` — real CDC (`prim_fifo_async` + `prim_sync_reqack`) from `io_div4`
- 1× `ergo_setup_gen` — deliberate, parameterized (`NumStages`, currently uniform default 8) unpipelined setup violation
- The 5 clocks that are themselves *derived* (`exp_div2`, `exp_div8`, `main_div2`, `main_div10`, `usb_div4`, `exp2_div2`, `exp2_div6` — 7 total) each additionally get, paired with their parent root:
  - 1× `ergo_hold_gen` — deliberate unsynchronized root→derived crossing (hold/CDC violation)
  - 1× `ergo_cdc_hazard_gen` — self-checking bit-tearing hazard (`MISMATCH_COUNT` register)

Totals: 9 `ergo_cdc_bridge` + 9 `ergo_setup_gen` + 7 `ergo_hold_gen` + 7 `ergo_cdc_hazard_gen` = 32.

### Known loose ends

- `NumStages` not yet tuned per-instance (needs real synthesis gate-delay data first).
- `is_pow2()` assertion fails generating `xbar_cover.cfg` (DV coverage-exclusion config) for one crossbar — caught internally by topgen (`tlgen/generate_tb.py:51`'s bare `except`), doesn't abort generation, doesn't touch RTL. Low priority, not yet root-caused.
- topgen gotcha: `generate_clkmgr()` runs early/unconditionally; `generate_rstmgr()`/`generate_pwrmgr()` only run *after* `validate_top()` passes. Adding a new clock's port to `rstmgr_aon`'s declared `clock_srcs` in the *same* batch as the underlying `resets.nodes` additions creates a permanent mismatch that re-running does NOT self-heal (rstmgr never gets a chance to regenerate). Fix: add `resets.nodes` first, run topgen (rstmgr's real port list is driven by `resets.nodes` alone, independent of any declared `clock_srcs`), THEN add the matching `clock_srcs` declaration in a second pass.

## Baseline Yosys synthesis + pipeline formalization (2026-09-03)

First real Yosys synthesis of the full, untrimmed design (NanGate45/FreePDK45, `hw/top_earlgrey/syn_lib/NangateOpenCellLibrary_typical.lib`). Result, via `hierarchy -check -top top_earlgrey` → `synth` → `dfflibmap` → `abc` → `stat -liberty`, then a post-hoc `flatten; stat` for a true multiplicity-aware total:

- **~1,370,600 standard cells** (1,413,089 raw `stat` cell count minus 42,474 non-physical `$scopeinfo` debug markers and 34 `$logic_not`), plus 22 unmapped generic RAM macros.
- Total chip area: 2,267,594 liberty units, 34.4% sequential.
- Confirms the obvious: full stock-derived earlgrey is ~14-27x over the 50-100K target — the deferred peripheral-trimming pass is a hard requirement, not headroom.

Then formalized the whole ad hoc synth debugging session into real, checked-in, reproducible scripts under `hw/../util/nebula/` (i.e. `opentitan/util/nebula/`), per explicit request ("colleagues shouldn't need AI to figure out which commands to run"):

- `clocks.py` — show/check/set clock freq+divisor in the hjson, enforcing the real constraints found this session (even divisors — `prim_generic_clock_div.sv`'s `ASSERT_INIT(DivEven_A)`; derived freq must exactly equal src/div; every non-aon master's freq must be an integer multiple of aon's 200kHz, or clkmgr's `int(freq/aon_freq)` measurement-threshold generation silently truncates instead of erroring; `aon` locked by default; `usb`'s 48MHz flagged as conventional-but-not-enforced). **Explicitly did not fabricate an STA-driven max-frequency ceiling** — no SDC/OpenSTA exists in this repo yet, so `check` validates mechanical/structural correctness only, not timing closure.
- `run_topgen.sh`, `run_verilator_build.sh`, `gen_sv2v_filelist.py`, `sv2v_convert.sh`, `synth_yosys.sh`, `build_benchmark.sh` — full pipeline, each independently runnable. `gen_sv2v_filelist.py` reads fusesoc's own `eda.yml` (from `fusesoc run --target=syn --setup`) instead of re-deriving the file list by hand.
- `README.md` in that dir documents all of the above plus the clock-leeway writeup in more detail than this note.

Real bugs found and fixed while building/testing this (not just workarounds — root causes):
1. `top_earlgrey.core` never depended on `lowrisc:systems:pinmux_reg:0.1` (the core packaging topgen's own generated `pinmux_reg_pkg.sv`/`pinmux_reg_top.sv`) — fusesoc silently omitted these files from its own resolution. Added the dependency; fusesoc now resolves everything itself, no manual file-list patching needed (this is what looked like an sv2v-specific mystery in the earlier ad hoc debugging session — it was never sv2v's fault).
2. `prim_assert.sv`'s `` `ifdef VERILATOR / `elsif SYNTHESIS / `elsif YOSYS / `else `` chain rewritten to nested `` `ifdef/`else/`endif `` (sv2v doesn't support `` `elsif ``).
3. The real root cause of a recurring "ASSERT macro expansion" sv2v parse failure on SVA repetition syntax (`[*2]` etc, in `prim_alert_receiver.sv`): the file-list generator was passing `.svh` files fusesoc marks `is_include_file: true` as direct top-level sv2v arguments, not just `-I` targets. `prim_assert_standard_macros.svh` (full real-SVA `` `ASSERT ``) was therefore read unconditionally later in file order and silently clobbered the correct SYNTHESIS-safe dummy-macro definition for every file processed afterward. Fixed in `gen_sv2v_filelist.py` by respecting `is_include_file`.
4. A regression from earlier this session: `csrng_core.sv`'s `.data_i` port connection had been source-edited to `.data_i(1'b0)` purely to dodge an sv2v codegen quirk — but this broke real SystemVerilog semantics (`data_i` is an array port) and made **Verilator fail to elaborate**. Fixed by using `'{default: '0}` (matching `edn_core.sv`'s already-proven-good identical instantiation of `prim_arbiter_ppc`), which satisfies both Verilator and sv2v/Yosys simultaneously — confirmed by diffing the generated `.v` output against `edn_core.v`'s pattern (`sv2v_uu_...` synthetic wire, not a raw `'{...}` literal).

Validation approach: re-ran `sv2v_convert.sh` twice from a completely clean `build-nebula/`+fresh `fusesoc --setup` — both times 654/654 files converted with zero errors/warnings. Started a full `synth_yosys.sh` re-run to confirm the corrected `csrng_core.sv` still synthesizes end-to-end; let it run ~15 minutes (healthy — no errors, ~2.9GB RSS, 99% single-core CPU, not the OOM-risk pattern seen on an earlier attempt at the untrimmed design) before deciding, together with the user, that this was redundant: the Yosys TCL logic itself is byte-identical to the one that already fully completed once this session (the baseline numbers above), and every change since then was independently verified through faster, targeted checks (fusesoc's own dependency resolution, a minimal sv2v repro, two clean full sv2v passes, and a direct `.v`-output diff against known-good precedent). Killed the redundant run rather than burn another ~1-2h of wall clock re-confirming what was already evidenced piecewise. **Caveat**: the `area.rpt`/`top_earlgrey_netlist.v` currently on disk predate the `csrng_core.sv` fix — they're the untrimmed-baseline numbers above, not a fresh post-fix re-synthesis. Re-run `util/nebula/synth_yosys.sh` (or `build_benchmark.sh`) once before treating a specific netlist file as current/deliverable, rather than trusting the stale one on disk.

## SDC generation (2026-09-04)

Prompted by a direct question: does the AI-optimizer flow need an SDC before the netlist is usable as its input? Yes — without a target clock period there's no basis for "this is a timing violation," and the CDC boundaries the `ergo_*` IPs sit on need explicit async/sync treatment or STA would either miss the real crossings or flag the deliberately-safe ones as false positives.

Added `util/nebula/gen_sdc.py`, wired into `build_benchmark.sh` as step 4/4. It writes `hw/top_earlgrey/syn_out/top_earlgrey.sdc`, derived entirely from things already declared elsewhere (no new hand-maintained source of truth):

- **Master clocks**: `create_clock` on all 6 top-level ports (`clk_{main,io,usb,aon,exp,exp2}_i`), periods computed from `top_earlgrey.hjson`'s frequencies via `clocks.py`'s existing `ClockConfig` parser.
- **Generated clocks**: `create_generated_clock` for all 9 derived clocks, `-source` the corresponding master port, `-divide_by` the declared divisor, targeting `u_clkmgr_aon/u_no_scan_<name>_div/clk_o` — verified this instance-naming convention (`u_no_scan_<name>_div`, output pin `clk_o`) against both `clkmgr.sv`'s source and the synthesized netlist (hierarchy is preserved post-synthesis; Yosys's `synth -top` does not flatten by default, confirmed via `grep -c "^module "` showing 1422 distinct modules in the netlist, not one flat module).
- **Clock groups**: `set_clock_groups -asynchronous`, one group per oscillator *family* (a master + everything derived from it), not per clock pair. This one decision is what makes the constraint set actually match the benchmark's intent — checked against `ergo_manifest.yaml`'s per-instance clock pairs:
  - `ergo_hold_gen`/`ergo_cdc_hazard_gen` cross between a master and its *own* derived clock (e.g. `exp` → `exp_div2`) — same family, so they stay in one `set_clock_groups` group and get properly analyzed as a real synchronous generated-clock relationship. This is essential: these are the IPs whose entire deliberate violation depends on the two clocks' edges having a known, computable relationship (divider insertion-delay skew) — grouping them as unrelated/async would make the injected hold violation unmeasurable.
  - `ergo_cdc_bridge` (all instances) crosses `io_div4` into an unrelated family (`exp`/`exp2`/`main`/`usb` trees) — different families, so it's asynchronous by construction, matching what it actually is: a reference-correct crossing (`prim_fifo_async` + `prim_sync_reqack`) that must never be flagged as an ordinary sync setup/hold violation.
  - `ergo_setup_gen`'s violation is intra-domain (`operand_gen_q`→`chain_result`, both in `clk_gen_i`) — doesn't depend on cross-domain group treatment at all, just needs `clk_gen_i`'s period defined correctly, which it is.

Deliberately **not** modeled: input/output delay on top-level IO/pad ports (`mio_*`, `dio_*`, `ast_*`, `flash_*`, `otp_*`, `scan_*`, ...). None of this benchmark's injected violations touch chip-boundary ports — they're all IP-internal — and this repo has no real package/board timing spec to derive plausible delay numbers from. Inventing IO timing with no grounding would be worse than leaving those paths unconstrained; if that's ever needed, it needs an actual spec behind it, not fabricated values.

Also deliberately **not** built: an actual STA run. OpenSTA isn't installed in this environment and per project convention (prefer package-manager installs, don't build from source) wasn't pulled in just to self-check this file — instead validated by construction: every `get_ports`/`get_pins` reference in the generated SDC was checked to actually exist (top-level port names read directly off `top_earlgrey.sv`'s module header; divider instance/pin names grep-confirmed present in both `clkmgr.sv` and the synthesized netlist for all 9 derived clocks). Running a real STA tool against this SDC (and reporting actual timing violations, not just a structural area report) is the next real step — tracked as the evaluator work, same as before; this SDC is meant to be a ready input for that, not proof of timing closure by itself.

Verified output: `util/nebula/gen_sdc.py` run standalone produces exactly 6 `create_clock`, 9 `create_generated_clock`, and 6 `set_clock_groups` entries (one group per family: `aon`, `exp`+`exp_div2`+`exp_div8`, `exp2`+`exp2_div2`+`exp2_div6`, `io`+`io_div2`+`io_div4`, `main`+`main_div2`+`main_div10`, `usb`+`usb_div4`) — matches the clock tree exactly, no manual correction needed.

## Trimming experiment: Ibex config + Yosys share/opt -full (2026-09-04)

Prompted by: "is there any way to trim it so that the cell count is lower? let's explore all the strategies." Before proposing anything, pulled a real per-IP breakdown out of `area.rpt`'s final `stat -liberty` summary (the file has many intermediate `stat` snapshots from synthesis sub-passes — only the very last block, cross-checked against the total cell count, is authoritative). Top contributors at the time (898,268 cells total): `rv_core_ibex` ~107.6K (12.0%), `kmac` ~106.4K (11.8%), `entropy_src` ~73.4K (8.2%), `csrng` ~72.2K (8.0%), `flash_ctrl` ~65.5K (7.3%), `keymgr` ~52.3K (5.8%), `otp_ctrl` ~51.8K (5.8%), `alert_handler` ~42.6K (4.7%). Confirmed `alert_handler` isn't a separate lever — it's topgen-templated (`NAlerts` = total alert count across included modules, `alert_handler.hjson.tpl`'s `${n_alerts}`), so it shrinks automatically as a side effect of removing any other module.

Picked two cheap, zero-structural-risk strategies to try first:
- **A — Ibex parameter tuning**: `top_earlgrey.hjson`'s `rv_core_ibex` `param_decl` had `ICache: 1, ICacheECC: 1, ICacheScramble: 1` (a full scrambled+ECC-protected icache) and `PMPNumRegions: 16`. Set `ICache`/`ICacheECC`/`ICacheScramble` to `0` and `PMPNumRegions` to `4`. Pure hjson edit, no RTL surgery — `RV32M` was already `RV32MSingleCycle` (the area-optimal choice, not the default `RV32MFast`), so nothing left there; `RV32B`/`SecureIbex` deliberately untouched since those trade away real ISA/countermeasure functionality, not synthesis fat.
- **B — Yosys-level optimization**: added `yosys share` + `yosys opt -full` to `syn_top_earlgrey.tcl` between `synth -top` and `dfflibmap`, to see if resource sharing / a full convergence sweep found anything the default `synth` script's own passes missed.

**Bug hit before the test could even run**: `build_benchmark.sh` (and `run_topgen.sh`/`sv2v_convert.sh`/`synth_yosys.sh`) all `cd "$(git rev-parse --show-toplevel ...)"`. This was fine while `top_ergo` was its own git repo, but once it got folded into the outer `nebula-cogito` repo as a subdirectory (losing its own `.git`), `git rev-parse --show-toplevel` started resolving to the *outer* repo root instead — meaning every script's relative paths (`util/nebula/run_topgen.sh`, etc.) silently pointed at the wrong tree. This had been dormant since the fold-in; nobody had re-run the full pipeline since. Fixed all four scripts to `cd` relative to their own script location (`cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"`) instead of relying on git.

**Second, bigger hazard hit once topgen actually ran for real**: `run_topgen.sh` calls upstream OpenTitan's real `topgen.py` unrestricted, which regenerates `ip_autogen/*` wholesale — it deleted 332 previously-committed files (DV testbenches, docs, and critically `alert_handler.core`'s own dependency `alert_handler_component.core`), because topgen's actual output doesn't include everything that's currently committed there. This broke fusesoc's dependency resolution (`lowrisc:ip:alert_handler_component` unresolvable) and would have silently discarded real project content if not caught. Restored everything via `git checkout` (safe — nothing from this had been committed). **Conclusion: don't run `run_topgen.sh` (or `build_benchmark.sh` without `--skip-topgen`) casually — it doesn't actually reproduce the currently-committed `ip_autogen/` tree.** The original committed state must have been produced by a more complete process (e.g. run from within a full OpenTitan checkout) than this repo's own trimmed `run_topgen.sh` can reproduce. Also creates an untracked `top_ergo/sw/` (device/host headers) that's out of this project's stated scope (no SW/DV) — deleted it. This is a real, unresolved gap in the "everything regenerates from source" story and needs a proper fix or explicit documentation, not just a one-off `git checkout`.

**Result** (after restoring the deleted files and re-running from sv2v conversion onward, A+B combined): 898,268 → 854,041 cells (‑4.9%), area 1,493,889 → 1,424,739 µm² (‑4.6%). Attribution, from comparing per-IP area in the final `stat -liberty` block: `rv_core_ibex` alone went ~179,000 → ~109,000 area (‑39%), and **every other IP came back unchanged to 3 significant figures** (one exception: `gpio` ticked up slightly, 8,310→8,668 area, almost certainly synthesis run-to-run noise from a different local optimum, not a real regression). So **A accounts for essentially the entire design-wide reduction; B measurably bought nothing** — for ~35 extra minutes of runtime and a peak memory footprint (~8.2GB RSS) that came close to exhausting the machine's 15GB RAM (swap started engaging). Reverted B from `syn_top_earlgrey.tcl`; kept A. Re-running once more with the final (A-only, B-reverted) script to keep the committed netlist/area.rpt/SDC consistent with what the script on disk actually regenerates. **Final clean re-run: 854,531 cells** (490 more than the A+B number above, 0.06% — pure run-to-run synthesis noise, not a real difference; confirms again B added nothing). `top_earlgrey.sdc` came back byte-identical (its content only depends on clock topology, untouched by the Ibex change). This is the number now reflected in `README.md`.

**Why this matters more than "lower is nicer"**: the hackathon's own rules score the GenAI optimizer team on "minimal runtime and API costs, scaling proportionately with design size" — against a benchmark we hand them. Every cell we don't need to ship is runtime/cost they don't have to pay for something that isn't the actual challenge. This reframes the still-open `kmac`/`entropy_src`/`csrng` cluster (~252K cells, ~28% — bigger than initially scoped; entangled via `kmac.app`'s three consumers `keymgr`/`lc_ctrl`/`rom_ctrl`, confirmed via `top_earlgrey.hjson`'s `inter_module` block) and the `lc_ctrl`/`otp_ctrl`/`flash_ctrl`/`keymgr` cluster (~188K, ~21%) as more than nice-to-have — see updated `README.md`'s "Further trimming, not yet done".

## Hackathon requirements check + aon clock decision (2026-09-04)

User shared the hackathon's actual design-requirements checklist. Checked this benchmark against it directly: ≥5 async masters ✓ (6: `main`/`io`/`usb`/`aon`/`exp`/`exp2`), CDC ✓, divider logic with multiple ratios ✓ (÷2/4/6/8/10), ~50K+ cells ✓ (854,041) — but "≥1 generated clock per master" only holds for 5 of the 6: `aon` has zero derived clocks. This isn't an oversight — real OpenTitan's `clkmgr`/topgen structurally forbids deriving a clock *from* `aon` (see `util/nebula/README.md` §4), so we never gave it one.

Raised this as a real decision (not something to silently resolve): add a compliance-only synthetic divider off `aon`, or document `aon` as a bonus 6th master not counted toward the required 5 (since the other 5 already satisfy "≥5 masters, each with ≥1 generated clock" on their own). User chose the documentation route — no RTL change. Added a "Hackathon design requirements" table to `README.md` making this explicit and the reasoning traceable, rather than leaving it as a silent gap a judge might flag without context.

Also flagged, not yet acted on: `hw/top_earlgrey/data/ergo_manifest.yaml` is this benchmark's ground-truth answer key (exact violation type/location/closability per instance) — valuable for grading the optimizer's fix rate, but it must not be part of what the "blind, design-agnostic" optimizer itself reads, or the evaluation stops being blind. Worth flagging to whoever owns the scoring/evaluation piece once that work starts.

## Release packaging for the optimizer team (2026-09-04)

Prompted by: "draft a document ... that acts like a comprehensive To-Do manual ... you have to ensure that there's no cheating possible." Before drafting anything, checked what's actually in the repo that could leak the answer — found something worse than the manifest file: the `ergo_*` RTL source comments themselves spell out the exact defect, e.g. `ergo_hold_gen.sv:81` *"DELIBERATE VIOLATION: reg_a_q ... sampled directly by a clk_b_i-domain flop with no synchronizer"* and even *"Do not 'fix' this with a synchronizer."* Handing over RTL as-is would have been a much bigger leak than `ergo_manifest.yaml` ever was.

Resolution: the hackathon's own rules say the benchmark-providing team may submit *either* RTL or a netlist — so netlist-only is fully compliant, not a workaround. A synthesized netlist has no comments (Yosys strips them), which closes this leak entirely for free, and it's the same choice already made for iteration-speed reasons (see the earlier RTL-vs-netlist architecture discussion). Residual leak: hierarchical instance names in the netlist (`ergo_hold_gen0`, etc.) still semantically hint at violation type. Asked the user whether to also anonymize module/instance names before the final synth run (~30-40 min re-run cost) vs. ship as-is; user chose **ship as-is** — the naming hint is a much weaker signal than the RTL comments were, and closing it isn't worth the time cost right now.

Built the actual handoff, not just a written policy (a document alone can't guarantee "no cheating" if the underlying files are still sitting in the repo):

- **`RELEASE_MANUAL.md`** (repo root) — the full usage contract for whoever's agent consumes this: what's provided (netlist/SDC/liberty/area-summary only), why netlist-not-RTL, the exact Yosys/liberty toolchain the baseline was produced with, how to read the SDC's clock-group semantics, the formal-equivalence gate (EQY, mandatory, checked against the *original* netlist), anti-gaming rules (no stuck-value tie-offs disguised as optimization), and explicit rules of engagement (treat the design as a black box; don't infer intent from instance names; don't seek out anything beyond the listed files even if visible through some other channel).
- **`util/nebula/package_release.sh`** — assembles `release/` (gitignored, regenerated on demand) containing exactly: `top_earlgrey_netlist.v`, `top_earlgrey.sdc`, the liberty file, `RELEASE_MANUAL.md`, and `reference_area_summary.txt`. That last one matters: `area.rpt` is a 37K-line multi-pass synthesis log (every intermediate `stat` snapshot plus a full recursive per-submodule dump) — handing it over as-is risks the recipient reading a stale mid-synthesis number by mistake (exactly the confusion this session hit while analyzing per-IP cell counts earlier today). The script extracts only the final "Count/Area including submodules" summary block (found by locating the *last* occurrence of that header, not the first) into a clean ~90-line file instead.
- Added `release/` to `.gitignore` — same reasoning as `build/`/`build-nebula/`: fully regenerable from already-tracked files, not worth committing a redundant copy.

Verified: ran `package_release.sh`, confirmed `reference_area_summary.txt`'s cell total (854,531) matches the real final number, not a mid-synthesis one.



