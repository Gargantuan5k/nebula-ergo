// Copyright lowRISC contributors (OpenTitan project).
// Copyright Gargantuan5k, 2026 (modifications: exp clock domain).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//############################################################################
// *Name: exp_osc
// *Module Description: Expansion Clock Oscilator
//############################################################################

module exp_osc (
  input vcore_pok_h_i,    // VCORE POK @3.3V
  input exp_en_i,         // Expansion Source Clock Enable
  input exp_jen_i,        // Expansion Source Clock Jitter Enable
  input exp_osc_cal_i,    // Expansion Oscillator Calibrated
`ifdef AST_BYPASS_CLK
  input clk_exp_ext_i,    // FPGA/VERILATOR Clock input
`endif
  output logic exp_clk_o  // Expansion Clock Output
);

`ifndef AST_BYPASS_CLK
`ifndef SYNTHESIS
// Behavioral Model
////////////////////////////////////////
timeunit  1ns / 1ps;

real CLK_PERIOD;

reg init_start;
initial init_start = 1'b0;
logic [16-1:0] jrate, jrate_cnt;

initial begin
  jrate = 16'(1 << $urandom_range(7, 0)) - 1'b1;
  #1;
  init_start  = 1'b1;
  #1;
  $display("\n%m: Expansion Clock Power-up Frequency: %0d Hz", $rtoi(10**9/CLK_PERIOD));
end

// Enable 5us RC Delay on rise
wire en_osc_re_buf, en_osc_re, exp_jen;
buf #(ast_bhv_pkg::SYS_EN_RDLY, 0) b0 (en_osc_re_buf, (vcore_pok_h_i && exp_en_i));
assign en_osc_re = en_osc_re_buf && init_start;
assign exp_jen = exp_jen_i && en_osc_re_buf && init_start;

// Clock Oscillator
////////////////////////////////////////
real CalExpClkPeriod, UncExpClkPeriod, ExpClkPeriod, jitter;

// 13889ps = 1/72MHz
initial CalExpClkPeriod = $itor( 13889 );

initial UncExpClkPeriod = $itor( $urandom_range(40000, 16667) );  // 40000-16667ps (25-60MHz)

assign ExpClkPeriod = (exp_osc_cal_i && init_start) ? CalExpClkPeriod : UncExpClkPeriod;

logic clk;

// -20% Jitter on calibrated frequency
always_ff (* xprop_off *) @( posedge clk, negedge vcore_pok_h_i ) begin
  if ( !vcore_pok_h_i ) begin
    jitter <= 0.0;
    jrate_cnt <= '0;
  end else if ( !exp_jen ) begin
    jrate_cnt <= '0;
    jitter <= 0.0;
  end else if ( jrate_cnt == '0 ) begin
    jrate_cnt <= jrate;
    jitter <= $itor($urandom_range(3472, 0));  // ~20% of 13889ps
  end else if ( jrate_cnt > '0 ) begin
    jrate_cnt <= jrate_cnt - 1'b1;
  end
end

assign CLK_PERIOD = (ExpClkPeriod + jitter)/1000;

// Free running oscillator
reg clk_osc;
initial clk_osc = 1'b1;

always begin
  #(CLK_PERIOD/2) clk_osc = ~clk_osc;
end

logic en_osc;

// HDL Clock Gate
logic en_clk;

always_latch begin
  if ( !clk_osc ) en_clk = en_osc;
end

assign clk = clk_osc && en_clk;
`else  // of SYNTHESIS
// SYNTHESIS/LINTER
///////////////////////////////////////
logic en_osc_re;
assign en_osc_re = vcore_pok_h_i && exp_en_i;

logic clk, en_osc;
assign clk = 1'b0;
`endif  // of SYNTHESIS
`else  // of AST_BYPASS_CLK
// VERILATOR/FPGA
///////////////////////////////////////
logic en_osc_re;
assign en_osc_re = vcore_pok_h_i && exp_en_i;

// Clock Oscillator
////////////////////////////////////////
logic clk, en_osc;

prim_clock_gating #(
  .NoFpgaGate ( 1'b1 )
) u_clk_ckgt (
  .clk_i ( clk_exp_ext_i ),
  .en_i ( en_osc ),
  .test_en_i ( 1'b0 ),
  .clk_o ( clk )
);
`endif

logic en_osc_fe;

// Syncronize en_osc to clk FE for glitch free disable
always_ff @( negedge clk, negedge vcore_pok_h_i ) begin
  if ( !vcore_pok_h_i ) begin
    en_osc_fe <= 1'b0;
  end else begin
    en_osc_fe <= en_osc_re;
  end
end

assign en_osc = en_osc_re || en_osc_fe;  // EN -> 1 || EN -> 0

// Clock Output Buffer
////////////////////////////////////////
prim_clock_buf #(
  .NoFpgaBuf ( 1'b1 )
) u_buf (
  .clk_i ( clk ),
  .clk_o ( exp_clk_o )
);


`ifdef SYNTHESIS
/////////////////////////
// Unused Signals
/////////////////////////
logic unused_sigs;
assign unused_sigs = ^{ exp_osc_cal_i, exp_jen_i };
`endif

endmodule : exp_osc
