// Copyright lowRISC contributors (OpenTitan project).
// Copyright Gargantuan5k, 2026 (new IP: ergo_setup_gen).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ergo_setup_gen: latches an operand from clk_i (io_div4) via prim_fifo_async,
// runs it through a deliberately unpipelined multiply-accumulate chain
// entirely within clk_gen_i, and reports the result back via
// prim_sync_reqack. The chain is a known, documented, deliberately-injected
// setup-violation source for nebula-cogito timing-closure benchmarking (see
// notes.md) -- NumStages is a tunable knob, not a hidden constant.

`include "prim_assert.sv"

module ergo_setup_gen #(
  parameter int unsigned NumStages = 4
) (
  input clk_i,
  input rst_ni,

  input clk_gen_i,
  input rst_gen_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o
);

  import ergo_setup_gen_reg_pkg::*;

  ergo_setup_gen_reg2hw_t reg2hw;
  ergo_setup_gen_hw2reg_t hw2reg;

  // Write side (clk_i): OPERAND_IN write pushes an operand into the async FIFO.
  logic [15:0] fifo_wdata;
  logic        fifo_wvalid, fifo_wready;
  logic [2:0]  fifo_wdepth;

  assign fifo_wdata  = reg2hw.operand_in.q;
  assign fifo_wvalid = reg2hw.operand_in.qe;

  logic [15:0] fifo_rdata;
  logic        fifo_rvalid, fifo_rready;
  logic [2:0]  fifo_rdepth;

  prim_fifo_async #(
    .Width(16),
    .Depth(4)
  ) u_fifo (
    .clk_wr_i  (clk_i),
    .rst_wr_ni (rst_ni),
    .wvalid_i  (fifo_wvalid),
    .wready_o  (fifo_wready),
    .wdata_i   (fifo_wdata),
    .wdepth_o  (fifo_wdepth),

    .clk_rd_i  (clk_gen_i),
    .rst_rd_ni (rst_gen_ni),
    .rvalid_o  (fifo_rvalid),
    .rready_i  (fifo_rready),
    .rdata_o   (fifo_rdata),
    .rdepth_o  (fifo_rdepth)
  );

  logic unused_sigs;
  assign unused_sigs = ^{fifo_wready, fifo_wdepth, fifo_rdepth};

  // clk_gen_i domain: latch the operand, run it through the deliberately
  // unpipelined chain, register the result, then hand it off via req/ack --
  // gated so the next operand isn't popped until the current result has been
  // acknowledged back in clk_i, same rate-independent pattern as
  // ergo_cdc_bridge.
  typedef enum logic { StIdle, StWaitAck } gen_state_e;
  gen_state_e gen_state_q, gen_state_d;

  logic        result_req_gen, result_ack_gen;
  logic [15:0] operand_gen_q;
  logic [31:0] result_gen_q;

  assign fifo_rready = fifo_rvalid && (gen_state_q == StIdle);

  always_comb begin
    gen_state_d    = gen_state_q;
    result_req_gen = 1'b0;
    unique case (gen_state_q)
      StIdle: begin
        if (fifo_rready) begin
          gen_state_d = StWaitAck;
        end
      end
      StWaitAck: begin
        result_req_gen = 1'b1;
        if (result_ack_gen) begin
          gen_state_d = StIdle;
        end
      end
      default: gen_state_d = StIdle;
    endcase
  end

  always_ff @(posedge clk_gen_i or negedge rst_gen_ni) begin
    if (!rst_gen_ni) begin
      gen_state_q   <= StIdle;
      operand_gen_q <= '0;
      result_gen_q  <= '0;
    end else begin
      gen_state_q <= gen_state_d;
      if (fifo_rready) begin
        operand_gen_q <= fifo_rdata;
      end
      if (gen_state_q == StIdle && fifo_rready) begin
        result_gen_q <= chain_result;
      end
    end
  end

  // Deliberately unpipelined MAC chain -- NumStages multiply-adds, no
  // intermediate registers, purely feedforward between operand_gen_q and
  // chain_result. NumStages natural pipeline-insertion points exist at every
  // acc_stage boundary; a closure-competent optimizer can meet any target
  // period by inserting up to NumStages registers along this chain, since
  // nothing downstream assumes fixed latency (req/ack handshake only).
  logic [31:0] acc_stage [NumStages+1];
  assign acc_stage[0] = {16'h0, operand_gen_q};

  for (genvar i = 0; i < NumStages; i++) begin : gen_mac_stage
    localparam logic [31:0] Coeff = 32'h9E3779B1 ^ (i * 32'h0100_0001);
    assign acc_stage[i+1] = (acc_stage[i] * Coeff[15:0]) + {16'h0, operand_gen_q};
  end : gen_mac_stage

  logic [31:0] chain_result;
  assign chain_result = acc_stage[NumStages];

  logic result_event_wclk;
  logic dst_ack_q;

  prim_sync_reqack u_result_sync (
    .clk_src_i  (clk_gen_i),
    .rst_src_ni (rst_gen_ni),
    .clk_dst_i  (clk_i),
    .rst_dst_ni (rst_ni),

    .req_chk_i  (1'b1),

    .src_req_i  (result_req_gen),
    .src_ack_o  (result_ack_gen),
    .dst_req_o  (result_event_wclk),
    .dst_ack_i  (dst_ack_q)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      dst_ack_q <= 1'b0;
    end else begin
      dst_ack_q <= result_event_wclk;
    end
  end

  // result_gen_q is only written while gen_state_q == StIdle (i.e. right
  // before a request starts), and held stable throughout the whole
  // StWaitAck round trip, so sampling it in clk_i once result_event_wclk
  // pulses is a safe, stable multi-bit crossing.
  logic [31:0] result_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      result_q <= '0;
    end else if (result_event_wclk) begin
      result_q <= result_gen_q;
    end
  end

  assign hw2reg.result.d  = result_q;
  assign hw2reg.result.de = 1'b1;

  logic unused_intg_err;

  ergo_setup_gen_reg_top u_reg (
    .clk_i,
    .rst_ni,

    .tl_i,
    .tl_o,

    .reg2hw,
    .hw2reg,

    .intg_err_o (unused_intg_err)
  );

endmodule : ergo_setup_gen
