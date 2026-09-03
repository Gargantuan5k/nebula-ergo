// Copyright lowRISC contributors (OpenTitan project).
// Copyright Siddharth Vivek, 2026 (modifications: exp clock domain).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//############################################################################
// *Name: exp_clk
// *Module Description: Expansion Clock
//############################################################################

module exp_clk (
  input clk_src_exp_jen_i,           // Expansion Source Clock Jitter Enable
  input clk_src_exp_en_i,            // Expansion Source Clock Enable
  input clk_exp_pd_ni,               // Expansion Clock Power-down
  input rst_exp_clk_ni,              // Expansion Clock Logic reset
  input vcore_pok_h_i,               // VCORE POK @3.3V (for OSC)
  input scan_mode_i,                 // Scan Mode
  input exp_osc_cal_i,               // Expansion Oscillator Calibrated
`ifdef AST_BYPASS_CLK
  input clk_exp_ext_i,               // FPGA/VERILATOR Clock input
`endif
  output logic clk_src_exp_o,        // Expansion Source Clock
  output logic clk_src_exp_val_o     // Expansion Source Clock Valid
);

logic clk, osc_en, exp_clk_en;

assign osc_en = (clk_src_exp_en_i && clk_exp_pd_ni && rst_exp_clk_ni);
assign exp_clk_en = scan_mode_i || osc_en;

// Clock Oscilator
///////////////////////////////////////
exp_osc u_exp_osc (
  .vcore_pok_h_i ( vcore_pok_h_i ),
  .exp_en_i ( exp_clk_en ),
  .exp_jen_i ( clk_src_exp_jen_i ),
  .exp_osc_cal_i ( exp_osc_cal_i ),
`ifdef AST_BYPASS_CLK
  .clk_exp_ext_i ( clk_exp_ext_i ),
`endif
  .exp_clk_o ( clk )
);  // of u_exp_osc

// Clock & Valid
///////////////////////////////////////
prim_clock_buf #(
  .NoFpgaBuf ( 1'b1 )
) u_clk_exp_buf(
  .clk_i ( clk ),
  .clk_o ( clk_src_exp_o )
);

// 2-stage de-assertion
logic rst_val_n;
assign rst_val_n = exp_clk_en;

prim_flop_2sync #(
  .Width ( 1 ),
  .ResetValue ( 1'b0 )
) u_no_scan_val_sync (
  .clk_i ( clk_src_exp_o ),
  .rst_ni ( rst_val_n ),
  .d_i ( 1'b1 ),
  .q_o ( clk_src_exp_val_o )
);

endmodule : exp_clk
