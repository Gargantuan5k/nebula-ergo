// Copyright lowRISC contributors (OpenTitan project).
// Copyright Gargantuan5k, 2026 (modifications: exp2 clock domain).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//############################################################################
// *Name: exp2_clk
// *Module Description: Expansion 2 Clock
//############################################################################

module exp2_clk (
  input clk_src_exp2_jen_i,           // Expansion 2 Source Clock Jitter Enable
  input clk_src_exp2_en_i,            // Expansion 2 Source Clock Enable
  input clk_exp2_pd_ni,               // Expansion 2 Clock Power-down
  input rst_exp2_clk_ni,              // Expansion 2 Clock Logic reset
  input vcore_pok_h_i,                // VCORE POK @3.3V (for OSC)
  input scan_mode_i,                  // Scan Mode
  input exp2_osc_cal_i,               // Expansion 2 Oscillator Calibrated
`ifdef AST_BYPASS_CLK
  input clk_exp2_ext_i,               // FPGA/VERILATOR Clock input
`endif
  output logic clk_src_exp2_o,        // Expansion 2 Source Clock
  output logic clk_src_exp2_val_o     // Expansion 2 Source Clock Valid
);

logic clk, osc_en, exp2_clk_en;

assign osc_en = (clk_src_exp2_en_i && clk_exp2_pd_ni && rst_exp2_clk_ni);
assign exp2_clk_en = scan_mode_i || osc_en;

// Clock Oscilator
///////////////////////////////////////
exp2_osc u_exp2_osc (
  .vcore_pok_h_i ( vcore_pok_h_i ),
  .exp2_en_i ( exp2_clk_en ),
  .exp2_jen_i ( clk_src_exp2_jen_i ),
  .exp2_osc_cal_i ( exp2_osc_cal_i ),
`ifdef AST_BYPASS_CLK
  .clk_exp2_ext_i ( clk_exp2_ext_i ),
`endif
  .exp2_clk_o ( clk )
);  // of u_exp2_osc

// Clock & Valid
///////////////////////////////////////
prim_clock_buf #(
  .NoFpgaBuf ( 1'b1 )
) u_clk_exp2_buf(
  .clk_i ( clk ),
  .clk_o ( clk_src_exp2_o )
);

// 2-stage de-assertion
logic rst_val_n;
assign rst_val_n = exp2_clk_en;

prim_flop_2sync #(
  .Width ( 1 ),
  .ResetValue ( 1'b0 )
) u_no_scan_val_sync (
  .clk_i ( clk_src_exp2_o ),
  .rst_ni ( rst_val_n ),
  .d_i ( 1'b1 ),
  .q_o ( clk_src_exp2_val_o )
);

endmodule : exp2_clk
