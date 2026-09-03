set fp [open $::env(SYN_VLIST) r]
while {[gets $fp line] >= 0} {
  if {$line eq ""} { continue }
  yosys read_verilog -sv $line
}
close $fp
yosys hierarchy -check -top top_earlgrey
yosys synth -top top_earlgrey
yosys dfflibmap -liberty $::env(SYN_LIBERTY)
yosys abc -liberty $::env(SYN_LIBERTY)
yosys clean -purge
yosys write_verilog $::env(SYN_OUTDIR)/top_earlgrey_netlist.v
yosys tee -o $::env(SYN_OUTDIR)/area.rpt stat -liberty $::env(SYN_LIBERTY)
