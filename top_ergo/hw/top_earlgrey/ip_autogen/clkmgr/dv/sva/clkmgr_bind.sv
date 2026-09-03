// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module clkmgr_bind;
`ifndef GATE_LEVEL
  bind clkmgr tlul_assert #(
    .EndpointType("Device")
  ) tlul_assert_device (.clk_i, .rst_ni, .h2d(tl_i), .d2h(tl_o));

  // In top-level testbench, do not bind the csr_assert_fpv to reduce simulation time.
`ifndef TOP_LEVEL_DV
  bind clkmgr clkmgr_csr_assert_fpv clkmgr_csr_assert (.clk_i, .rst_ni, .h2d(tl_i), .d2h(tl_o));
`endif

  bind clkmgr clkmgr_pwrmgr_sva_if #(.IS_USB(0)) clkmgr_pwrmgr_main_sva_if (
    .clk_i,
    .rst_ni,
    .clk_en(pwr_i.main_ip_clk_en),
    .status(pwr_o.main_status)
  );

  bind clkmgr clkmgr_pwrmgr_sva_if #(.IS_USB(0)) clkmgr_pwrmgr_io_sva_if (
    .clk_i,
    .rst_ni,
    .clk_en(pwr_i.io_ip_clk_en),
    .status(pwr_o.io_status)
  );

  bind clkmgr clkmgr_pwrmgr_sva_if #(.IS_USB(1)) clkmgr_pwrmgr_usb_sva_if (
    .clk_i,
    .rst_ni,
    .clk_en(pwr_i.usb_ip_clk_en),
    .status(pwr_o.usb_status)
  );

  bind clkmgr clkmgr_pwrmgr_sva_if #(.IS_USB(0)) clkmgr_pwrmgr_exp_sva_if (
    .clk_i,
    .rst_ni,
    .clk_en(pwr_i.exp_ip_clk_en),
    .status(pwr_o.exp_status)
  );

  bind clkmgr clkmgr_pwrmgr_sva_if #(.IS_USB(0)) clkmgr_pwrmgr_exp2_sva_if (
    .clk_i,
    .rst_ni,
    .clk_en(pwr_i.exp2_ip_clk_en),
    .status(pwr_o.exp2_status)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_io_div4_peri_sva_if (
    .clk(clocks_o.clk_io_div4_powerup),
    .rst_n(rst_io_div4_ni),
    .ip_clk_en(pwr_i.io_ip_clk_en),
    .sw_clk_en(clk_io_div4_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_io_div4_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_io_div2_peri_sva_if (
    .clk(clocks_o.clk_io_div2_powerup),
    .rst_n(rst_io_div2_ni),
    .ip_clk_en(pwr_i.io_ip_clk_en),
    .sw_clk_en(clk_io_div2_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_io_div2_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_exp_peri_sva_if (
    .clk(clocks_o.clk_exp_powerup),
    .rst_n(rst_exp_ni),
    .ip_clk_en(pwr_i.exp_ip_clk_en),
    .sw_clk_en(clk_exp_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_exp_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_exp_div2_peri_sva_if (
    .clk(clocks_o.clk_exp_div2_powerup),
    .rst_n(rst_exp_div2_ni),
    .ip_clk_en(pwr_i.exp_ip_clk_en),
    .sw_clk_en(clk_exp_div2_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_exp_div2_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_exp_div8_peri_sva_if (
    .clk(clocks_o.clk_exp_div8_powerup),
    .rst_n(rst_exp_div8_ni),
    .ip_clk_en(pwr_i.exp_ip_clk_en),
    .sw_clk_en(clk_exp_div8_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_exp_div8_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_main_div2_peri_sva_if (
    .clk(clocks_o.clk_main_div2_powerup),
    .rst_n(rst_main_div2_ni),
    .ip_clk_en(pwr_i.main_ip_clk_en),
    .sw_clk_en(clk_main_div2_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_main_div2_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_main_div10_peri_sva_if (
    .clk(clocks_o.clk_main_div10_powerup),
    .rst_n(rst_main_div10_ni),
    .ip_clk_en(pwr_i.main_ip_clk_en),
    .sw_clk_en(clk_main_div10_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_main_div10_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_usb_div4_peri_sva_if (
    .clk(clocks_o.clk_usb_div4_powerup),
    .rst_n(rst_usb_div4_ni),
    .ip_clk_en(pwr_i.usb_ip_clk_en),
    .sw_clk_en(clk_usb_div4_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_usb_div4_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_main_peri_sva_if (
    .clk(clocks_o.clk_main_powerup),
    .rst_n(rst_main_ni),
    .ip_clk_en(pwr_i.main_ip_clk_en),
    .sw_clk_en(clk_main_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_main_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_usb_peri_sva_if (
    .clk(clocks_o.clk_usb_powerup),
    .rst_n(rst_usb_ni),
    .ip_clk_en(pwr_i.usb_ip_clk_en),
    .sw_clk_en(clk_usb_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_usb_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_exp2_peri_sva_if (
    .clk(clocks_o.clk_exp2_powerup),
    .rst_n(rst_exp2_ni),
    .ip_clk_en(pwr_i.exp2_ip_clk_en),
    .sw_clk_en(clk_exp2_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_exp2_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_exp2_div2_peri_sva_if (
    .clk(clocks_o.clk_exp2_div2_powerup),
    .rst_n(rst_exp2_div2_ni),
    .ip_clk_en(pwr_i.exp2_ip_clk_en),
    .sw_clk_en(clk_exp2_div2_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_exp2_div2_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_exp2_div6_peri_sva_if (
    .clk(clocks_o.clk_exp2_div6_powerup),
    .rst_n(rst_exp2_div6_ni),
    .ip_clk_en(pwr_i.exp2_ip_clk_en),
    .sw_clk_en(clk_exp2_div6_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_exp2_div6_peri)
  );

  bind clkmgr clkmgr_gated_clock_sva_if clkmgr_io_peri_sva_if (
    .clk(clocks_o.clk_io_powerup),
    .rst_n(rst_io_ni),
    .ip_clk_en(pwr_i.io_ip_clk_en),
    .sw_clk_en(clk_io_peri_sw_en),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .gated_clk(clocks_o.clk_io_peri)
  );

  // Assertions for transactional clocks.
  bind clkmgr clkmgr_trans_sva_if clkmgr_kmac_trans_sva_if (
    .clk(clk_main_i),
    .rst_n(rst_main_ni),
    .hint(reg2hw.clk_hints.clk_main_kmac_hint.q),
    .idle(idle_i[HintMainKmac] == prim_mubi_pkg::MuBi4True),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True),
    .status(hw2reg.clk_hints_status.clk_main_kmac_val.d),
    .trans_clk(clocks_o.clk_main_kmac)
  );

  bind clkmgr clkmgr_extclk_sva_if clkmgr_extclk_sva_if (
    .clk_i,
    .rst_ni,
    .extclk_ctrl_sel,
    .extclk_ctrl_hi_speed_sel,
    .lc_hw_debug_en_i,
    .lc_clk_byp_req_i,
    .io_clk_byp_req_o,
    .all_clk_byp_req_o,
    .hi_speed_sel_o
  );

  bind clkmgr clkmgr_div_sva_if #(
    .DIV(2)
  ) clkmgr_div2_sva_if (
    .clk(clocks_o.clk_io_powerup),
    .rst_n(rst_ni),
    .maybe_divided_clk(clocks_o.clk_io_div2_powerup),
    .div_step_down_req_i(div_step_down_req_i == prim_mubi_pkg::MuBi4True),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True)
  );

  // The div2 clk also steps, so not a good reference. Instead, check it always tracks io_div2.
  bind clkmgr clkmgr_div_sva_if #(
    .DIV(4)
  ) clkmgr_div4_sva_if (
    .clk(clocks_o.clk_io_div2_powerup),
    .rst_n(rst_ni),
    .maybe_divided_clk(clocks_o.clk_io_div4_powerup),
    .div_step_down_req_i(div_step_down_req_i == prim_mubi_pkg::MuBi4True),
    .scanmode(scanmode_i == prim_mubi_pkg::MuBi4True)
  );

  // AON clock gating enables.
  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_aon_peri (
    .cg_en(cg_en_o.aon_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_aon_powerup (
    .cg_en(cg_en_o.aon_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_aon_timers (
    .cg_en(cg_en_o.aon_timers == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_exp2_div2_powerup (
    .cg_en(cg_en_o.exp2_div2_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_exp2_div6_powerup (
    .cg_en(cg_en_o.exp2_div6_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_exp2_powerup (
    .cg_en(cg_en_o.exp2_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_exp_div2_powerup (
    .cg_en(cg_en_o.exp_div2_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_exp_div8_powerup (
    .cg_en(cg_en_o.exp_div8_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_exp_powerup (
    .cg_en(cg_en_o.exp_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_io_div2_powerup (
    .cg_en(cg_en_o.io_div2_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_io_div4_powerup (
    .cg_en(cg_en_o.io_div4_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_io_powerup (
    .cg_en(cg_en_o.io_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_main_div10_powerup (
    .cg_en(cg_en_o.main_div10_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_main_div2_powerup (
    .cg_en(cg_en_o.main_div2_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_main_powerup (
    .cg_en(cg_en_o.main_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_usb_div4_powerup (
    .cg_en(cg_en_o.usb_div4_powerup == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_aon_cg_en_sva_if clkmgr_aon_cg_usb_powerup (
    .cg_en(cg_en_o.usb_powerup == prim_mubi_pkg::MuBi4True)
  );

  // Non-AON clock gating enables with no software control.
  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_io_div4_infra (
    .clk(clk_io_div4),
    .rst_n(rst_io_div4_ni),
    .ip_clk_en(clk_io_div4_en),
    .sw_clk_en(1'b1),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.io_div4_infra == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_io_div4_secure (
    .clk(clk_io_div4),
    .rst_n(rst_io_div4_ni),
    .ip_clk_en(clk_io_div4_en),
    .sw_clk_en(1'b1),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.io_div4_secure == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_io_div4_timers (
    .clk(clk_io_div4),
    .rst_n(rst_io_div4_ni),
    .ip_clk_en(clk_io_div4_en),
    .sw_clk_en(1'b1),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.io_div4_timers == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_io_infra (
    .clk(clk_io),
    .rst_n(rst_io_ni),
    .ip_clk_en(clk_io_en),
    .sw_clk_en(1'b1),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.io_infra == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_main_infra (
    .clk(clk_main),
    .rst_n(rst_main_ni),
    .ip_clk_en(clk_main_en),
    .sw_clk_en(1'b1),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.main_infra == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_main_secure (
    .clk(clk_main),
    .rst_n(rst_main_ni),
    .ip_clk_en(clk_main_en),
    .sw_clk_en(1'b1),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.main_secure == prim_mubi_pkg::MuBi4True)
  );

  // Software controlled gating enables.
  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_io_div4_peri (
    .clk(clk_io_div4),
    .rst_n(rst_io_div4_ni),
    .ip_clk_en(clk_io_div4_en),
    .sw_clk_en(clk_io_div4_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.io_div4_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_io_div2_peri (
    .clk(clk_io_div2),
    .rst_n(rst_io_div2_ni),
    .ip_clk_en(clk_io_div2_en),
    .sw_clk_en(clk_io_div2_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.io_div2_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_exp_peri (
    .clk(clk_exp),
    .rst_n(rst_exp_ni),
    .ip_clk_en(clk_exp_en),
    .sw_clk_en(clk_exp_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.exp_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_exp_div2_peri (
    .clk(clk_exp_div2),
    .rst_n(rst_exp_div2_ni),
    .ip_clk_en(clk_exp_div2_en),
    .sw_clk_en(clk_exp_div2_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.exp_div2_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_exp_div8_peri (
    .clk(clk_exp_div8),
    .rst_n(rst_exp_div8_ni),
    .ip_clk_en(clk_exp_div8_en),
    .sw_clk_en(clk_exp_div8_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.exp_div8_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_main_div2_peri (
    .clk(clk_main_div2),
    .rst_n(rst_main_div2_ni),
    .ip_clk_en(clk_main_div2_en),
    .sw_clk_en(clk_main_div2_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.main_div2_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_main_div10_peri (
    .clk(clk_main_div10),
    .rst_n(rst_main_div10_ni),
    .ip_clk_en(clk_main_div10_en),
    .sw_clk_en(clk_main_div10_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.main_div10_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_usb_div4_peri (
    .clk(clk_usb_div4),
    .rst_n(rst_usb_div4_ni),
    .ip_clk_en(clk_usb_div4_en),
    .sw_clk_en(clk_usb_div4_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.usb_div4_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_main_peri (
    .clk(clk_main),
    .rst_n(rst_main_ni),
    .ip_clk_en(clk_main_en),
    .sw_clk_en(clk_main_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.main_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_usb_peri (
    .clk(clk_usb),
    .rst_n(rst_usb_ni),
    .ip_clk_en(clk_usb_en),
    .sw_clk_en(clk_usb_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.usb_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_exp2_peri (
    .clk(clk_exp2),
    .rst_n(rst_exp2_ni),
    .ip_clk_en(clk_exp2_en),
    .sw_clk_en(clk_exp2_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.exp2_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_exp2_div2_peri (
    .clk(clk_exp2_div2),
    .rst_n(rst_exp2_div2_ni),
    .ip_clk_en(clk_exp2_div2_en),
    .sw_clk_en(clk_exp2_div2_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.exp2_div2_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_exp2_div6_peri (
    .clk(clk_exp2_div6),
    .rst_n(rst_exp2_div6_ni),
    .ip_clk_en(clk_exp2_div6_en),
    .sw_clk_en(clk_exp2_div6_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.exp2_div6_peri == prim_mubi_pkg::MuBi4True)
  );

  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_io_peri (
    .clk(clk_io),
    .rst_n(rst_io_ni),
    .ip_clk_en(clk_io_en),
    .sw_clk_en(clk_io_peri_sw_en),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.io_peri == prim_mubi_pkg::MuBi4True)
  );

  // Hint controlled gating enables.
  bind clkmgr clkmgr_cg_en_sva_if clkmgr_cg_main_kmac (
    .clk(clk_main_i),
    .rst_n(rst_main_ni),
    .ip_clk_en(clk_main_en),
    .sw_clk_en(u_clk_main_kmac_trans.sw_hint_synced || !u_clk_main_kmac_trans.idle_valid),
    .scanmode(prim_mubi_pkg::MuBi4False),
    .cg_en(cg_en_o.main_kmac == prim_mubi_pkg::MuBi4True)
  );

  // Calibration assertions.
  bind clkmgr clkmgr_lost_calib_regwen_sva_if clkmgr_lost_calib_regwen_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_regwen(u_reg.measure_ctrl_regwen_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_exp_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.exp_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_exp2_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.exp2_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_io_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.io_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_main_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.main_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_usb_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.usb_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_io_div2_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.io_div2_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_io_div4_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.io_div4_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_main_div2_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.main_div2_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_main_div10_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.main_div10_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_usb_div4_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.usb_div4_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_exp_div2_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.exp_div2_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_exp_div8_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.exp_div8_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_exp2_div2_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.exp2_div2_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_lost_calib_ctrl_en_sva_if clkmgr_lost_calib_exp2_div6_ctrl_en_sva_if (
    .clk(clk_i),
    .rst_n(rst_ni),
    .calib_rdy(calib_rdy_i),
    .meas_ctrl_en(u_reg.exp2_div6_meas_ctrl_en_qs)
  );

  bind clkmgr clkmgr_sec_cm_checker_assert clkmgr_sec_cm_checker_assert (
    .clk_i,
    .rst_ni,
    .all_clk_byp_req_o,
    .lc_hw_debug_en_i,
    .lc_clk_byp_req_i,
    .lc_clk_byp_ack_o,
    .io_clk_byp_req_o,
    // internal signal is picked due to inconsistent t->f, f->t delay
    .io_clk_byp_ack(u_clkmgr_byp.io_clk_byp_ack),
    // internal signal is picked due to inconsistent input to signal delay
    .step_down_acks_sync(u_clkmgr_byp.step_down_acks_sync),
    .extclk_ctrl_sel
  );
`endif
endmodule : clkmgr_bind
