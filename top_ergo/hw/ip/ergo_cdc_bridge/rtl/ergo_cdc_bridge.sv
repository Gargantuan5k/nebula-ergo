// Copyright lowRISC contributors (OpenTitan project).
// Copyright Gargantuan5k, 2026 (new IP: ergo_cdc_bridge).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ergo_cdc_bridge: bridges DATA_IN writes (clk_i domain) through a real async
// FIFO into an independently-clocked consumer (clk_rd_i domain), and reports
// pop events back to clk_i via a rate-independent req/ack synchronizer. Exists
// to give benchmark-only clock domains a real, synthesizable consumer with a
// genuine CDC boundary (see nebula-cogito notes).

`include "prim_assert.sv"

module ergo_cdc_bridge import ergo_cdc_bridge_reg_pkg::*; (
  input clk_i,
  input rst_ni,

  input clk_rd_i,
  input rst_rd_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o
);

  ergo_cdc_bridge_reg2hw_t reg2hw;
  ergo_cdc_bridge_hw2reg_t hw2reg;

  // Write side (clk_i): DATA_IN write pushes a byte into the async FIFO.
  logic [7:0] fifo_wdata;
  logic       fifo_wvalid, fifo_wready;
  logic [2:0] fifo_wdepth;

  assign fifo_wdata  = reg2hw.data_in.q;
  assign fifo_wvalid = reg2hw.data_in.qe;

  assign hw2reg.fifo_status.empty.d  = (fifo_wdepth == '0);
  assign hw2reg.fifo_status.empty.de = 1'b1;
  assign hw2reg.fifo_status.full.d   = (fifo_wdepth == 3'd4);
  assign hw2reg.fifo_status.full.de  = 1'b1;

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

    .clk_rd_i  (clk_rd_i),
    .rst_rd_ni (rst_rd_ni),
    .rvalid_o  (fifo_rvalid),
    .rready_i  (fifo_rready),
    .rdata_o   (fifo_rdata),
    .rdepth_o  (fifo_rdepth)
  );

  // fifo_wready and fifo_rdata content are not consumed further: wready_o
  // isn't backpressured (DATA_IN writes when full simply overwrite the
  // youngest slot per prim_fifo_async's own behavior), and the popped byte's
  // value doesn't matter here -- only the pop *event* is real payload.
  logic unused_sigs;
  assign unused_sigs = ^{fifo_wready, fifo_rdata};

  // Read side (clk_rd_i): always ready to pop one word at a time, gated by
  // the req/ack round trip so consecutive pops can't outrun the synchronizer
  // regardless of the clk_i/clk_rd_i frequency ratio (prim_sync_reqack is
  // documented safe for both faster-to-slower and slower-to-faster crossing).
  typedef enum logic { StIdle, StWaitAck } pop_state_e;
  pop_state_e pop_state_q, pop_state_d;

  logic pop_req_rd, pop_ack_rd;

  assign fifo_rready = fifo_rvalid && (pop_state_q == StIdle);

  always_comb begin
    pop_state_d = pop_state_q;
    pop_req_rd  = 1'b0;
    unique case (pop_state_q)
      StIdle: begin
        if (fifo_rready) begin
          pop_req_rd  = 1'b1;
          pop_state_d = StWaitAck;
        end
      end
      StWaitAck: begin
        pop_req_rd = 1'b1;
        if (pop_ack_rd) begin
          pop_state_d = StIdle;
        end
      end
      default: pop_state_d = StIdle;
    endcase
  end

  always_ff @(posedge clk_rd_i or negedge rst_rd_ni) begin
    if (!rst_rd_ni) begin
      pop_state_q <= StIdle;
    end else begin
      pop_state_q <= pop_state_d;
    end
  end

  logic pop_event_wclk;
  logic dst_ack_q;

  prim_sync_reqack u_pop_sync (
    .clk_src_i  (clk_rd_i),
    .rst_src_ni (rst_rd_ni),
    .clk_dst_i  (clk_i),
    .rst_dst_ni (rst_ni),

    .req_chk_i  (1'b1),

    .src_req_i  (pop_req_rd),
    .src_ack_o  (pop_ack_rd),
    .dst_req_o  (pop_event_wclk),
    .dst_ack_i  (dst_ack_q)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      dst_ack_q <= 1'b0;
    end else begin
      dst_ack_q <= pop_event_wclk;
    end
  end

  logic [31:0] pop_count_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pop_count_q <= '0;
    end else if (pop_event_wclk) begin
      pop_count_q <= pop_count_q + 32'd1;
    end
  end

  assign hw2reg.pop_count.d  = pop_count_q;
  assign hw2reg.pop_count.de = 1'b1;

  logic unused_intg_err;

  ergo_cdc_bridge_reg_top u_reg (
    .clk_i,
    .rst_ni,

    .tl_i,
    .tl_o,

    .reg2hw,
    .hw2reg,

    .intg_err_o (unused_intg_err)
  );

endmodule : ergo_cdc_bridge
