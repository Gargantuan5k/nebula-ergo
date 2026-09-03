// Copyright lowRISC contributors (OpenTitan project).
// Copyright Gargantuan5k, 2026 (new IP: ergo_hold_gen).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ergo_hold_gen: pushes a seed byte into clk_a_i via prim_fifo_async, then
// crosses it directly into clk_b_i (clk_a_i's own derived clock) with NO
// synchronizer. This is a known, deliberately-injected hold/CDC violation
// for nebula-cogito timing-closure benchmarking (see notes.md) -- everything
// else in this module uses correct primitives; only the reg_a_q -> reg_b_q
// hop below is intentionally naive.

`include "prim_assert.sv"

module ergo_hold_gen import ergo_hold_gen_reg_pkg::*; (
  input clk_i,
  input rst_ni,

  input clk_a_i,
  input rst_a_ni,

  input clk_b_i,
  input rst_b_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o
);

  ergo_hold_gen_reg2hw_t reg2hw;
  ergo_hold_gen_hw2reg_t hw2reg;

  // Write side (clk_i): SEED write pushes a byte into the async FIFO towards
  // clk_a_i. Correct, synchronized crossing.
  logic [7:0] fifo_wdata;
  logic       fifo_wvalid, fifo_wready;
  logic [2:0] fifo_wdepth;

  assign fifo_wdata  = reg2hw.seed.q;
  assign fifo_wvalid = reg2hw.seed.qe;

  logic [7:0] fifo_rdata;
  logic       fifo_rvalid, fifo_rready;
  logic [2:0] fifo_rdepth;

  prim_fifo_async #(
    .Width(8),
    .Depth(4)
  ) u_fifo (
    .clk_wr_i  (clk_i),
    .rst_wr_ni (rst_ni),
    .wvalid_i  (fifo_wvalid),
    .wready_o  (fifo_wready),
    .wdata_i   (fifo_wdata),
    .wdepth_o  (fifo_wdepth),

    .clk_rd_i  (clk_a_i),
    .rst_rd_ni (rst_a_ni),
    .rvalid_o  (fifo_rvalid),
    .rready_i  (fifo_rready),
    .rdata_o   (fifo_rdata),
    .rdepth_o  (fifo_rdepth)
  );

  logic unused_sigs;
  assign unused_sigs = ^{fifo_wready, fifo_wdepth, fifo_rdepth};

  // clk_a_i domain: always ready, latch each popped byte.
  assign fifo_rready = fifo_rvalid;

  logic [7:0] reg_a_q;

  always_ff @(posedge clk_a_i or negedge rst_a_ni) begin
    if (!rst_a_ni) begin
      reg_a_q <= '0;
    end else if (fifo_rready) begin
      reg_a_q <= fifo_rdata;
    end
  end

  // ---------------------------------------------------------------------
  // DELIBERATE VIOLATION: reg_a_q (a clk_a_i-domain flop) is sampled
  // directly by a clk_b_i-domain flop with no synchronizer, and clk_b_i is
  // clk_a_i's own derived clock -- exploiting the divider's insertion-delay
  // skew from its source. This is the known, documented hold/CDC violation
  // this module exists to inject. Do not "fix" this with a synchronizer.
  // ---------------------------------------------------------------------
  logic [7:0] reg_b_q;

  always_ff @(posedge clk_b_i or negedge rst_b_ni) begin
    if (!rst_b_ni) begin
      reg_b_q <= '0;
    end else begin
      reg_b_q <= reg_a_q ^ 8'hFF;
    end
  end

  // Read back safely: reg_b_q -> clk_i via prim_flop_2sync.
  logic [7:0] captured_sync;

  prim_flop_2sync #(
    .Width      (8),
    .ResetValue (8'h0)
  ) u_captured_sync (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .d_i    (reg_b_q),
    .q_o    (captured_sync)
  );

  assign hw2reg.captured.d  = captured_sync;
  assign hw2reg.captured.de = 1'b1;

  logic unused_intg_err;

  ergo_hold_gen_reg_top u_reg (
    .clk_i,
    .rst_ni,

    .tl_i,
    .tl_o,

    .reg2hw,
    .hw2reg,

    .intg_err_o (unused_intg_err)
  );

endmodule : ergo_hold_gen
