// Copyright lowRISC contributors (OpenTitan project).
// Copyright Gargantuan5k, 2026 (new IP: ergo_cdc_hazard_gen).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ergo_cdc_hazard_gen: free-runs a counter in clk_a_i and crosses it into
// clk_b_i two ways -- an unsynchronized direct capture (the deliberate
// hazard) and a Gray-coded crossing through prim_flop_2sync (safe, same
// technique prim_fifo_async uses internally for its own pointers). A
// comparator flags disagreements; MISMATCH_COUNT reports how often the
// unsafe path actually tears. This is a known, documented, deliberately-
// injected CDC data-integrity violation for nebula-cogito timing-closure
// benchmarking (see notes.md) -- do not "fix" the unsafe path with a
// synchronizer, that's the point of this module.

`include "prim_assert.sv"

module ergo_cdc_hazard_gen import ergo_cdc_hazard_gen_reg_pkg::*; (
  input clk_i,
  input rst_ni,

  input clk_a_i,
  input rst_a_ni,

  input clk_b_i,
  input rst_b_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o
);

  ergo_cdc_hazard_gen_hw2reg_t hw2reg;

  function automatic logic [15:0] gray_encode16(logic [15:0] bin);
    return bin ^ (bin >> 1);
  endfunction

  function automatic logic [15:0] gray_decode16(logic [15:0] g);
    logic [15:0] b;
    b[15] = g[15];
    for (int i = 14; i >= 0; i--) begin
      b[i] = b[i+1] ^ g[i];
    end
    return b;
  endfunction

  function automatic logic [31:0] gray_encode32(logic [31:0] bin);
    return bin ^ (bin >> 1);
  endfunction

  function automatic logic [31:0] gray_decode32(logic [31:0] g);
    logic [31:0] b;
    b[31] = g[31];
    for (int i = 30; i >= 0; i--) begin
      b[i] = b[i+1] ^ g[i];
    end
    return b;
  endfunction

  // ---------------------------------------------------------------------
  // clk_a_i: free-running counter, always active (guarantees regular
  // multi-bit transitions, not just an occasional software-triggered one).
  // ---------------------------------------------------------------------
  logic [15:0] ctr_a_q;

  always_ff @(posedge clk_a_i or negedge rst_a_ni) begin
    if (!rst_a_ni) begin
      ctr_a_q <= '0;
    end else begin
      ctr_a_q <= ctr_a_q + 16'd1;
    end
  end

  logic [15:0] gray_a_q;
  assign gray_a_q = gray_encode16(ctr_a_q);

  // ---------------------------------------------------------------------
  // DELIBERATE VIOLATION: ctr_a_q sampled directly in clk_b_i, no
  // synchronizer, no gray coding. Multiple bits can be mid-transition when
  // this samples (e.g. every 16-count wraparound), risking a torn value.
  // ---------------------------------------------------------------------
  logic [15:0] unsafe_bin_q;

  always_ff @(posedge clk_b_i or negedge rst_b_ni) begin
    if (!rst_b_ni) begin
      unsafe_bin_q <= '0;
    end else begin
      unsafe_bin_q <= ctr_a_q;
    end
  end

  // Safe reference: Gray-coded crossing through prim_flop_2sync (only one
  // bit of a Gray-coded value ever changes per source-domain cycle, so a
  // plain double-flop synchronizer is safe here).
  logic [15:0] gray_b_synced;

  prim_flop_2sync #(
    .Width      (16),
    .ResetValue (16'h0)
  ) u_gray_sync (
    .clk_i  (clk_b_i),
    .rst_ni (rst_b_ni),
    .d_i    (gray_a_q),
    .q_o    (gray_b_synced)
  );

  logic [15:0] safe_bin;
  assign safe_bin = gray_decode16(gray_b_synced);

  // Comparator + mismatch counter, both in clk_b_i.
  logic [31:0] mismatch_count_q;

  always_ff @(posedge clk_b_i or negedge rst_b_ni) begin
    if (!rst_b_ni) begin
      mismatch_count_q <= '0;
    end else if (unsafe_bin_q != safe_bin) begin
      mismatch_count_q <= mismatch_count_q + 32'd1;
    end
  end

  // Read MISMATCH_COUNT back to clk_i the same safe way (Gray-coded
  // counter, so a plain double-flop sync is valid).
  logic [31:0] mismatch_gray_b;
  assign mismatch_gray_b = gray_encode32(mismatch_count_q);

  logic [31:0] mismatch_gray_synced;

  prim_flop_2sync #(
    .Width      (32),
    .ResetValue (32'h0)
  ) u_mismatch_sync (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .d_i    (mismatch_gray_b),
    .q_o    (mismatch_gray_synced)
  );

  assign hw2reg.mismatch_count.d  = gray_decode32(mismatch_gray_synced);
  assign hw2reg.mismatch_count.de = 1'b1;

  logic unused_intg_err;

  ergo_cdc_hazard_gen_reg_top u_reg (
    .clk_i,
    .rst_ni,

    .tl_i,
    .tl_o,

    .hw2reg,

    .intg_err_o (unused_intg_err)
  );

endmodule : ergo_cdc_hazard_gen
