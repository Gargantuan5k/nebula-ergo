# top_ergo Benchmark — Usage Manual

This document is the complete usage contract for this benchmark. It is written to be
handed directly to an autonomous agent driving a GenAI timing-closure optimization
engine. Read this before writing any code against the provided files.

## 1. What this is

A gate-level synthesized netlist of an OpenTitan-derived SoC design (`top_earlgrey`),
built as a timing-closure optimization benchmark. It is provided as a **netlist + SDC**,
not RTL — see §3 for why, and §9 for what that means for how you're expected to work.

The design satisfies the following structural requirements:

| requirement | this design |
|---|---|
| ≥5 independent asynchronous master clock domains | 6 master clocks |
| ≥1 generated clock derived from each master | 5 of the 6 masters have one or more generated (divided) clocks; the 6th is a legitimate always-on/root clock domain with no children — see §6 |
| Clock Domain Crossings (CDC) between async domains | present, at multiple points |
| Clock divider logic, multiple division ratios | present (divisors of 2, 4, 6, 8, 10) |
| Design size | ~854,500 standard cells (NanGate45) |

Exact clock names, frequencies, and topology are in `top_earlgrey.sdc` (§6) — that file is
the authoritative, complete description of the clock structure. Nothing above should be
treated as more specific than what the SDC itself states.

## 2. What you are given

Exactly these files, in this release:

```
top_earlgrey_netlist.v      gate-level structural netlist (NanGate45 std cells)
top_earlgrey.sdc            clock definitions + clock-group constraints (see §6)
NangateOpenCellLibrary_typical.lib   the liberty file the netlist is mapped against
reference_area_summary.txt  cell-count/area report for THIS netlist, as shipped (your baseline to improve on)
RELEASE_MANUAL.md           this file
```

No other file is part of this benchmark. If you have access to anything beyond this list
(a wider repository, git history, unrelated documentation), it is out of scope — see §9.

## 3. Why netlist, not RTL

This benchmark's design-requirements source allows either RTL or a netlist as the
submitted design under test. A netlist was chosen deliberately: it is the actual input
your optimization engine needs to act on regardless (per the problem statement, your
engine must "identify critical and potential timing paths in the RTL/netlist" and operate
**design-agnostically** — nothing about this benchmark should require RTL-level context
to work on). Treat the netlist as the design. Do not attempt to obtain, request, or
reconstruct the source RTL this was synthesized from — it is not part of the benchmark
and any assumptions derived from guessing at it are out of scope for scoring.

## 4. Toolchain this was produced with

- **Synthesis**: Yosys 0.58, generic `synth -top` (not timing-driven) → `dfflibmap` →
  `abc -liberty` against the NanGate45 liberty below → `clean -purge`. No resource-sharing
  or extra optimization passes beyond Yosys's own default `synth` script.
- **Liberty / cell library**: `NangateOpenCellLibrary_typical.lib` (NanGate45/FreePDK45),
  provided alongside the netlist. Use this exact file for any re-synthesis, STA, or
  cell-swap operation you perform — do not substitute a different liberty target, or
  timing/area numbers stop being comparable to the shipped baseline.
- **No SRAM macros are modeled**: memory arrays appear as generic, un-mapped primitives
  in the netlist (you'll see "area unknown" for a couple of cell types if you run
  `stat -liberty` yourself) — this is expected, not an error. They're intentionally out
  of scope for this benchmark's timing-closure challenge.

You are free to use any STA engine, optimization methodology, or toolchain you choose on
top of this input — the above only describes how the *reference baseline* was produced,
so you can reproduce/compare against it consistently.

## 5. What "optimize" means here

Per the hackathon's own stated expectations, your engine is evaluated on:

1. PPA (power/performance/area) improvement over the provided baseline.
2. Turnaround time — how efficiently you get there.
3. Fix rate — the fraction of real timing issues in this design your engine actually
   resolves.
4. Where you *can't* fully resolve something, a clear account of why, and what
   additional input/constraint would help (this is asked for explicitly — a documented,
   honest "couldn't close this, and here's the specific reason" is a valid, expected
   outcome, not a failure to hide).

**Do not assume every path in this design is intended to be fully closable.** Some
issues here are structural or CDC-related in nature and may not respond to simple
retiming/pipelining. Treat "no further improvement possible without changing the
design's function" as a legitimate, reportable conclusion for a given path — don't force
a change that would require altering functional behavior to hit a slack target.

## 6. Understanding the SDC

`top_earlgrey.sdc` defines:

- `create_clock` for every master oscillator port.
- `create_generated_clock` for every derived/divided clock, each with an explicit
  `-source`/`-divide_by` relationship back to its master — this is a real, exact
  frequency relationship, not an approximation.
- `set_clock_groups -asynchronous`, one group per **oscillator family** (a master and
  everything derived from it) — clocks within the same group are related and should be
  analyzed together (including across any generated-clock relationship within that
  group); clocks in different groups are genuinely independent oscillators and must be
  treated as asynchronous to each other.

This grouping is the correct, complete statement of which clock relationships are real
and which are not. Do not infer additional relationships between clocks beyond what the
SDC states, and do not treat two clocks in different groups as having any fixed phase
relationship.

**Not modeled, deliberately**: input/output delay constraints on top-level chip
boundary ports. There is no package/board timing spec behind this netlist, so no
delay values are given for top-level ports — paths through them will not produce
meaningful slack numbers under any SDC-driven STA, and that's expected, not a gap for
you to fill with invented numbers.

## 7. Mandatory correctness gate: formal equivalence

**Any netlist your engine produces must be formally equivalent to the input netlist you
were given.** Use EQY (SymbiYosys/eqy) or an equivalent formal equivalence checker to
verify this before reporting any timing/area result.

- A candidate that fails equivalence is **invalid**, full stop, regardless of how good
  its reported timing or area looks. Do not report a timing win for a candidate that
  hasn't passed equivalence.
- Equivalence is checked against the **original provided netlist** (or, if you perform
  intermediate transformations, the immediately-prior valid netlist in your optimization
  chain) — never against a hand-description of "what the design is supposed to do."
- If your methodology only supports proving equivalence on part of the design at a time
  (e.g. module-scoped rather than whole-chip, likely necessary given this design's size),
  that's expected and fine — just be explicit in your reporting about what scope was
  equivalence-checked and what wasn't.

## 8. Structural sanity — don't game the metrics

A large area/cell-count reduction is not automatically a good result. Specifically watch
for, and do not do:

- Deleting or tying off logic to make it "disappear" from area/cell reports without a
  genuine equivalent transformation (equivalence checking in §7 should already catch
  this, but treat it as a hard rule, not just a check you might pass by luck).
- Constant-propagating an enable/control signal to a stuck value to eliminate the logic
  it gates, rather than actually optimizing the logic itself.
- Any transformation whose only justification is "the equivalence checker didn't scope
  over this part of the design."

Report cell count, FF count, combinational cell count, and area for both the input and
your output netlist, not just a single area delta number.

## 9. Rules of engagement

1. **Treat this design as a black box.** Discover critical/near-critical paths and
   violations through your own timing analysis against the provided SDC (§6) — not by
   inspecting module or instance names for hints about what they might do. Module and
   instance names in this netlist are structural artifacts of how the design was
   assembled, not documentation of intent.
2. **Do not seek out, request, or make use of any file, repository, or documentation
   beyond what's listed in §2.** If additional project files, commit history, or
   internal notes are visible to you through some channel outside this release, they
   are not part of the benchmark and must not inform your engine's behavior — using
   them constitutes an invalid result regardless of the score it would produce.
3. **Do not modify the provided SDC.** Your engine's timing analysis and final scoring
   are both computed against the SDC exactly as given. If your methodology needs
   additional constraints it isn't given (e.g. IO timing, see §6), report that as a
   documented gap per §5(4) — don't invent values and quietly add them.
4. **Your methodology must be design-agnostic.** Nothing in your engine's approach
   should be specific to this particular netlist's structure, naming, or module
   boundaries — the same engine should work on a different design meeting the same
   structural requirements (§1) without modification.

## 10. FAQ

**Q: Can I request the RTL this was synthesized from?**
No — see §3. The netlist is the benchmark.

**Q: The design is large (~854K cells). Do I need to optimize all of it?**
No single expectation exists that every cell/path be touched. Focus effort where your
own timing analysis shows real violations; report what you found and what you did about
it (§5).

**Q: What if my STA tool reports zero violations against this SDC?**
Double-check your tool is reading `top_earlgrey.sdc`'s clock groups correctly (§6) —
in particular, that clocks within the same oscillator family are being analyzed
together, not treated as mutually asynchronous. A correct read of the provided SDC
should surface real timing issues in this design.

**Q: Can I use a different liberty file or synthesis flow for my own iteration?**
Yes, for your own internal optimization loop — but the baseline you're compared against
(§4) is fixed to what's shipped. If you re-map to a different liberty target, your
final reported PPA numbers need to be re-derived against the original liberty for the
comparison to be meaningful, or explicitly caveated as non-comparable.
