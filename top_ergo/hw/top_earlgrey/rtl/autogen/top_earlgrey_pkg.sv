// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ------------------- W A R N I N G: A U T O - G E N E R A T E D   C O D E !! -------------------//
// PLEASE DO NOT HAND-EDIT THIS FILE. IT HAS BEEN AUTO-GENERATED WITH THE FOLLOWING COMMAND:
//
// util/topgen.py -t hw/top_earlgrey/data/top_earlgrey.hjson \
//                -o hw/top_earlgrey/ \
//                --rnd_cnst_seed \
//                1017106219537032642877583828875051302543807092889754935647094601236425074047

package top_earlgrey_pkg;
  /**
   * Peripheral base address for uart0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_UART0_BASE_ADDR = 32'h40000000;

  /**
   * Peripheral size in bytes for uart0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_UART0_SIZE_BYTES = 32'h40;

  /**
   * Peripheral base address for gpio in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_GPIO_BASE_ADDR = 32'h40040000;

  /**
   * Peripheral size in bytes for gpio in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_GPIO_SIZE_BYTES = 32'h40;

  /**
   * Peripheral base address for spi_device in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SPI_DEVICE_BASE_ADDR = 32'h40050000;

  /**
   * Peripheral size in bytes for spi_device in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SPI_DEVICE_SIZE_BYTES = 32'h2000;

  /**
   * Peripheral base address for ergo_cdc_bridge0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE0_BASE_ADDR = 32'h40060000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE0_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_cdc_bridge1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE1_BASE_ADDR = 32'h40070000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE1_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_cdc_bridge2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE2_BASE_ADDR = 32'h400B0000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE2_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_cdc_bridge3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE3_BASE_ADDR = 32'h400C0000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE3_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_cdc_bridge4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE4_BASE_ADDR = 32'h400D0000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE4_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_cdc_bridge5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE5_BASE_ADDR = 32'h40110000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE5_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_setup_gen0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN0_BASE_ADDR = 32'h40120000;

  /**
   * Peripheral size in bytes for ergo_setup_gen0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN0_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_setup_gen1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN1_BASE_ADDR = 32'h40160000;

  /**
   * Peripheral size in bytes for ergo_setup_gen1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN1_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_setup_gen2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN2_BASE_ADDR = 32'h40170000;

  /**
   * Peripheral size in bytes for ergo_setup_gen2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN2_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_setup_gen3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN3_BASE_ADDR = 32'h40180000;

  /**
   * Peripheral size in bytes for ergo_setup_gen3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN3_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_setup_gen4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN4_BASE_ADDR = 32'h40190000;

  /**
   * Peripheral size in bytes for ergo_setup_gen4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN4_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_setup_gen5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN5_BASE_ADDR = 32'h401A0000;

  /**
   * Peripheral size in bytes for ergo_setup_gen5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN5_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_hold_gen0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN0_BASE_ADDR = 32'h401B0000;

  /**
   * Peripheral size in bytes for ergo_hold_gen0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN0_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_hold_gen1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN1_BASE_ADDR = 32'h401C0000;

  /**
   * Peripheral size in bytes for ergo_hold_gen1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN1_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_hold_gen2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN2_BASE_ADDR = 32'h401D0000;

  /**
   * Peripheral size in bytes for ergo_hold_gen2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN2_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_hold_gen3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN3_BASE_ADDR = 32'h401E0000;

  /**
   * Peripheral size in bytes for ergo_hold_gen3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN3_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_hold_gen4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN4_BASE_ADDR = 32'h401F0000;

  /**
   * Peripheral size in bytes for ergo_hold_gen4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN4_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_cdc_hazard_gen0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN0_BASE_ADDR = 32'h40200000;

  /**
   * Peripheral size in bytes for ergo_cdc_hazard_gen0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN0_SIZE_BYTES = 32'h4;

  /**
   * Peripheral base address for ergo_cdc_hazard_gen1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN1_BASE_ADDR = 32'h40210000;

  /**
   * Peripheral size in bytes for ergo_cdc_hazard_gen1 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN1_SIZE_BYTES = 32'h4;

  /**
   * Peripheral base address for ergo_cdc_hazard_gen2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN2_BASE_ADDR = 32'h40220000;

  /**
   * Peripheral size in bytes for ergo_cdc_hazard_gen2 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN2_SIZE_BYTES = 32'h4;

  /**
   * Peripheral base address for ergo_cdc_hazard_gen3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN3_BASE_ADDR = 32'h40230000;

  /**
   * Peripheral size in bytes for ergo_cdc_hazard_gen3 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN3_SIZE_BYTES = 32'h4;

  /**
   * Peripheral base address for ergo_cdc_hazard_gen4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN4_BASE_ADDR = 32'h40240000;

  /**
   * Peripheral size in bytes for ergo_cdc_hazard_gen4 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN4_SIZE_BYTES = 32'h4;

  /**
   * Peripheral base address for ergo_cdc_bridge6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE6_BASE_ADDR = 32'h40250000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE6_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_cdc_bridge7 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE7_BASE_ADDR = 32'h40260000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge7 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE7_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_cdc_bridge8 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE8_BASE_ADDR = 32'h40270000;

  /**
   * Peripheral size in bytes for ergo_cdc_bridge8 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_BRIDGE8_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for ergo_setup_gen6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN6_BASE_ADDR = 32'h40280000;

  /**
   * Peripheral size in bytes for ergo_setup_gen6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN6_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_setup_gen7 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN7_BASE_ADDR = 32'h40290000;

  /**
   * Peripheral size in bytes for ergo_setup_gen7 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN7_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_setup_gen8 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN8_BASE_ADDR = 32'h402A0000;

  /**
   * Peripheral size in bytes for ergo_setup_gen8 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_SETUP_GEN8_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_hold_gen5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN5_BASE_ADDR = 32'h402B0000;

  /**
   * Peripheral size in bytes for ergo_hold_gen5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN5_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_hold_gen6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN6_BASE_ADDR = 32'h402C0000;

  /**
   * Peripheral size in bytes for ergo_hold_gen6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_HOLD_GEN6_SIZE_BYTES = 32'h8;

  /**
   * Peripheral base address for ergo_cdc_hazard_gen5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN5_BASE_ADDR = 32'h402D0000;

  /**
   * Peripheral size in bytes for ergo_cdc_hazard_gen5 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN5_SIZE_BYTES = 32'h4;

  /**
   * Peripheral base address for ergo_cdc_hazard_gen6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN6_BASE_ADDR = 32'h402E0000;

  /**
   * Peripheral size in bytes for ergo_cdc_hazard_gen6 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ERGO_CDC_HAZARD_GEN6_SIZE_BYTES = 32'h4;

  /**
   * Peripheral base address for i2c0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_I2C0_BASE_ADDR = 32'h40080000;

  /**
   * Peripheral size in bytes for i2c0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_I2C0_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for rv_timer in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_TIMER_BASE_ADDR = 32'h40100000;

  /**
   * Peripheral size in bytes for rv_timer in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_TIMER_SIZE_BYTES = 32'h200;

  /**
   * Peripheral base address for kmac in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_KMAC_BASE_ADDR = 32'h41120000;

  /**
   * Peripheral size in bytes for kmac in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_KMAC_SIZE_BYTES = 32'h1000;

  /**
   * Peripheral base address for core device on otp_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_OTP_CTRL_CORE_BASE_ADDR = 32'h40130000;

  /**
   * Peripheral size in bytes for core device on otp_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_OTP_CTRL_CORE_SIZE_BYTES = 32'h1000;

  /**
   * Peripheral base address for prim device on otp_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_OTP_CTRL_PRIM_BASE_ADDR = 32'h40138000;

  /**
   * Peripheral size in bytes for prim device on otp_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_OTP_CTRL_PRIM_SIZE_BYTES = 32'h20;

  /**
   * Peripheral base address for lc_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_LC_CTRL_BASE_ADDR = 32'h40140000;

  /**
   * Peripheral size in bytes for lc_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_LC_CTRL_SIZE_BYTES = 32'h100;

  /**
   * Peripheral base address for alert_handler in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ALERT_HANDLER_BASE_ADDR = 32'h40150000;

  /**
   * Peripheral size in bytes for alert_handler in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ALERT_HANDLER_SIZE_BYTES = 32'h800;

  /**
   * Peripheral base address for spi_host0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SPI_HOST0_BASE_ADDR = 32'h40300000;

  /**
   * Peripheral size in bytes for spi_host0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SPI_HOST0_SIZE_BYTES = 32'h40;

  /**
   * Peripheral base address for pwrmgr_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_PWRMGR_AON_BASE_ADDR = 32'h40400000;

  /**
   * Peripheral size in bytes for pwrmgr_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_PWRMGR_AON_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for rstmgr_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RSTMGR_AON_BASE_ADDR = 32'h40410000;

  /**
   * Peripheral size in bytes for rstmgr_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RSTMGR_AON_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for clkmgr_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_CLKMGR_AON_BASE_ADDR = 32'h40420000;

  /**
   * Peripheral size in bytes for clkmgr_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_CLKMGR_AON_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for pinmux_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_PINMUX_AON_BASE_ADDR = 32'h40460000;

  /**
   * Peripheral size in bytes for pinmux_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_PINMUX_AON_SIZE_BYTES = 32'h800;

  /**
   * Peripheral base address for aon_timer_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_AON_TIMER_AON_BASE_ADDR = 32'h40470000;

  /**
   * Peripheral size in bytes for aon_timer_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_AON_TIMER_AON_SIZE_BYTES = 32'h40;

  /**
   * Peripheral base address for ast in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_AST_BASE_ADDR = 32'h40480000;

  /**
   * Peripheral size in bytes for ast in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_AST_SIZE_BYTES = 32'h400;

  /**
   * Peripheral base address for regs device on sram_ctrl_ret_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_RET_AON_REGS_BASE_ADDR = 32'h40500000;

  /**
   * Peripheral size in bytes for regs device on sram_ctrl_ret_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_RET_AON_REGS_SIZE_BYTES = 32'h40;

  /**
   * Peripheral base address for ram device on sram_ctrl_ret_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_RET_AON_RAM_BASE_ADDR = 32'h40600000;

  /**
   * Peripheral size in bytes for ram device on sram_ctrl_ret_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_RET_AON_RAM_SIZE_BYTES = 32'h1000;

  /**
   * Peripheral base address for core device on flash_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_FLASH_CTRL_CORE_BASE_ADDR = 32'h41000000;

  /**
   * Peripheral size in bytes for core device on flash_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_FLASH_CTRL_CORE_SIZE_BYTES = 32'h200;

  /**
   * Peripheral base address for prim device on flash_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_FLASH_CTRL_PRIM_BASE_ADDR = 32'h41008000;

  /**
   * Peripheral size in bytes for prim device on flash_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_FLASH_CTRL_PRIM_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for mem device on flash_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_FLASH_CTRL_MEM_BASE_ADDR = 32'h20000000;

  /**
   * Peripheral size in bytes for mem device on flash_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_FLASH_CTRL_MEM_SIZE_BYTES = 32'h100000;

  /**
   * Peripheral base address for regs device on rv_dm in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_DM_REGS_BASE_ADDR = 32'h41200000;

  /**
   * Peripheral size in bytes for regs device on rv_dm in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_DM_REGS_SIZE_BYTES = 32'h10;

  /**
   * Peripheral base address for mem device on rv_dm in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_DM_MEM_BASE_ADDR = 32'h10000;

  /**
   * Peripheral size in bytes for mem device on rv_dm in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_DM_MEM_SIZE_BYTES = 32'h1000;

  /**
   * Peripheral base address for rv_plic in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_PLIC_BASE_ADDR = 32'h48000000;

  /**
   * Peripheral size in bytes for rv_plic in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_PLIC_SIZE_BYTES = 32'h8000000;

  /**
   * Peripheral base address for keymgr in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_KEYMGR_BASE_ADDR = 32'h41140000;

  /**
   * Peripheral size in bytes for keymgr in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_KEYMGR_SIZE_BYTES = 32'h100;

  /**
   * Peripheral base address for csrng in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_CSRNG_BASE_ADDR = 32'h41150000;

  /**
   * Peripheral size in bytes for csrng in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_CSRNG_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for entropy_src in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ENTROPY_SRC_BASE_ADDR = 32'h41160000;

  /**
   * Peripheral size in bytes for entropy_src in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ENTROPY_SRC_SIZE_BYTES = 32'h100;

  /**
   * Peripheral base address for edn0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_EDN0_BASE_ADDR = 32'h41170000;

  /**
   * Peripheral size in bytes for edn0 in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_EDN0_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for regs device on sram_ctrl_main in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_MAIN_REGS_BASE_ADDR = 32'h411C0000;

  /**
   * Peripheral size in bytes for regs device on sram_ctrl_main in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_MAIN_REGS_SIZE_BYTES = 32'h40;

  /**
   * Peripheral base address for ram device on sram_ctrl_main in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_MAIN_RAM_BASE_ADDR = 32'h10000000;

  /**
   * Peripheral size in bytes for ram device on sram_ctrl_main in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_SRAM_CTRL_MAIN_RAM_SIZE_BYTES = 32'h20000;

  /**
   * Peripheral base address for regs device on rom_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ROM_CTRL_REGS_BASE_ADDR = 32'h411E0000;

  /**
   * Peripheral size in bytes for regs device on rom_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ROM_CTRL_REGS_SIZE_BYTES = 32'h80;

  /**
   * Peripheral base address for rom device on rom_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ROM_CTRL_ROM_BASE_ADDR = 32'h8000;

  /**
   * Peripheral size in bytes for rom device on rom_ctrl in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ROM_CTRL_ROM_SIZE_BYTES = 32'h8000;

  /**
   * Peripheral base address for cfg device on rv_core_ibex in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_CORE_IBEX_CFG_BASE_ADDR = 32'h411F0000;

  /**
   * Peripheral size in bytes for cfg device on rv_core_ibex in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RV_CORE_IBEX_CFG_SIZE_BYTES = 32'h100;

  /**
   * Memory base address for ram_ret_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RAM_RET_AON_BASE_ADDR = 32'h40600000;

  /**
   * Memory size for ram_ret_aon in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RAM_RET_AON_SIZE_BYTES = 32'h1000;

  /**
   * Memory base address for eflash in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_EFLASH_BASE_ADDR = 32'h20000000;

  /**
   * Memory size for eflash in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_EFLASH_SIZE_BYTES = 32'h100000;

  /**
   * Memory base address for ram_main in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RAM_MAIN_BASE_ADDR = 32'h10000000;

  /**
   * Memory size for ram_main in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_RAM_MAIN_SIZE_BYTES = 32'h20000;

  /**
   * Memory base address for rom in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ROM_BASE_ADDR = 32'h8000;

  /**
   * Memory size for rom in top earlgrey.
   */
  parameter int unsigned TOP_EARLGREY_ROM_SIZE_BYTES = 32'h8000;


  // Enumeration of alert modules
  typedef enum int unsigned {
    TopEarlgreyAlertPeripheralUart0 = 0,
    TopEarlgreyAlertPeripheralGpio = 1,
    TopEarlgreyAlertPeripheralSpiDevice = 2,
    TopEarlgreyAlertPeripheralI2c0 = 3,
    TopEarlgreyAlertPeripheralRvTimer = 4,
    TopEarlgreyAlertPeripheralKmac = 5,
    TopEarlgreyAlertPeripheralOtpCtrl = 6,
    TopEarlgreyAlertPeripheralLcCtrl = 7,
    TopEarlgreyAlertPeripheralSpiHost0 = 8,
    TopEarlgreyAlertPeripheralPwrmgrAon = 9,
    TopEarlgreyAlertPeripheralRstmgrAon = 10,
    TopEarlgreyAlertPeripheralClkmgrAon = 11,
    TopEarlgreyAlertPeripheralPinmuxAon = 12,
    TopEarlgreyAlertPeripheralAonTimerAon = 13,
    TopEarlgreyAlertPeripheralSramCtrlRetAon = 14,
    TopEarlgreyAlertPeripheralFlashCtrl = 15,
    TopEarlgreyAlertPeripheralRvDm = 16,
    TopEarlgreyAlertPeripheralRvPlic = 17,
    TopEarlgreyAlertPeripheralKeymgr = 18,
    TopEarlgreyAlertPeripheralCsrng = 19,
    TopEarlgreyAlertPeripheralEntropySrc = 20,
    TopEarlgreyAlertPeripheralEdn0 = 21,
    TopEarlgreyAlertPeripheralSramCtrlMain = 22,
    TopEarlgreyAlertPeripheralRomCtrl = 23,
    TopEarlgreyAlertPeripheralRvCoreIbex = 24,
    TopEarlgreyAlertPeripheralCount
  } alert_peripheral_e;

  // Enumeration of alerts
  typedef enum int unsigned {
    TopEarlgreyAlertIdUart0FatalFault = 0,
    TopEarlgreyAlertIdGpioFatalFault = 1,
    TopEarlgreyAlertIdSpiDeviceFatalFault = 2,
    TopEarlgreyAlertIdI2c0FatalFault = 3,
    TopEarlgreyAlertIdRvTimerFatalFault = 4,
    TopEarlgreyAlertIdKmacRecovOperationErr = 5,
    TopEarlgreyAlertIdKmacFatalFaultErr = 6,
    TopEarlgreyAlertIdOtpCtrlFatalMacroError = 7,
    TopEarlgreyAlertIdOtpCtrlFatalCheckError = 8,
    TopEarlgreyAlertIdOtpCtrlFatalBusIntegError = 9,
    TopEarlgreyAlertIdOtpCtrlFatalPrimOtpAlert = 10,
    TopEarlgreyAlertIdOtpCtrlRecovPrimOtpAlert = 11,
    TopEarlgreyAlertIdLcCtrlFatalProgError = 12,
    TopEarlgreyAlertIdLcCtrlFatalStateError = 13,
    TopEarlgreyAlertIdLcCtrlFatalBusIntegError = 14,
    TopEarlgreyAlertIdSpiHost0FatalFault = 15,
    TopEarlgreyAlertIdPwrmgrAonFatalFault = 16,
    TopEarlgreyAlertIdRstmgrAonFatalFault = 17,
    TopEarlgreyAlertIdRstmgrAonFatalCnstyFault = 18,
    TopEarlgreyAlertIdClkmgrAonRecovFault = 19,
    TopEarlgreyAlertIdClkmgrAonFatalFault = 20,
    TopEarlgreyAlertIdPinmuxAonFatalFault = 21,
    TopEarlgreyAlertIdAonTimerAonFatalFault = 22,
    TopEarlgreyAlertIdSramCtrlRetAonFatalError = 23,
    TopEarlgreyAlertIdFlashCtrlRecovErr = 24,
    TopEarlgreyAlertIdFlashCtrlFatalStdErr = 25,
    TopEarlgreyAlertIdFlashCtrlFatalErr = 26,
    TopEarlgreyAlertIdFlashCtrlFatalPrimFlashAlert = 27,
    TopEarlgreyAlertIdFlashCtrlRecovPrimFlashAlert = 28,
    TopEarlgreyAlertIdRvDmFatalFault = 29,
    TopEarlgreyAlertIdRvPlicFatalFault = 30,
    TopEarlgreyAlertIdKeymgrRecovOperationErr = 31,
    TopEarlgreyAlertIdKeymgrFatalFaultErr = 32,
    TopEarlgreyAlertIdCsrngRecovAlert = 33,
    TopEarlgreyAlertIdCsrngFatalAlert = 34,
    TopEarlgreyAlertIdEntropySrcRecovAlert = 35,
    TopEarlgreyAlertIdEntropySrcFatalAlert = 36,
    TopEarlgreyAlertIdEdn0RecovAlert = 37,
    TopEarlgreyAlertIdEdn0FatalAlert = 38,
    TopEarlgreyAlertIdSramCtrlMainFatalError = 39,
    TopEarlgreyAlertIdRomCtrlFatal = 40,
    TopEarlgreyAlertIdRvCoreIbexFatalSwErr = 41,
    TopEarlgreyAlertIdRvCoreIbexRecovSwErr = 42,
    TopEarlgreyAlertIdRvCoreIbexFatalHwErr = 43,
    TopEarlgreyAlertIdRvCoreIbexRecovHwErr = 44,
    TopEarlgreyAlertIdCount
  } alert_id_e;

  // Enumeration of IO power domains.
  // Only used in ASIC target.
  typedef enum logic [2:0] {
    IoBankVcc = 0,
    IoBankAvcc = 1,
    IoBankVioa = 2,
    IoBankViob = 3,
    IoBankCount = 4
  } pwr_dom_e;

  // Enumeration for MIO signals on the top-level.
  typedef enum int unsigned {
    MioInGpioGpio0 = 0,
    MioInGpioGpio1 = 1,
    MioInGpioGpio2 = 2,
    MioInGpioGpio3 = 3,
    MioInGpioGpio4 = 4,
    MioInGpioGpio5 = 5,
    MioInGpioGpio6 = 6,
    MioInGpioGpio7 = 7,
    MioInGpioGpio8 = 8,
    MioInGpioGpio9 = 9,
    MioInGpioGpio10 = 10,
    MioInGpioGpio11 = 11,
    MioInGpioGpio12 = 12,
    MioInGpioGpio13 = 13,
    MioInGpioGpio14 = 14,
    MioInGpioGpio15 = 15,
    MioInGpioGpio16 = 16,
    MioInGpioGpio17 = 17,
    MioInGpioGpio18 = 18,
    MioInGpioGpio19 = 19,
    MioInGpioGpio20 = 20,
    MioInGpioGpio21 = 21,
    MioInGpioGpio22 = 22,
    MioInGpioGpio23 = 23,
    MioInGpioGpio24 = 24,
    MioInGpioGpio25 = 25,
    MioInGpioGpio26 = 26,
    MioInGpioGpio27 = 27,
    MioInGpioGpio28 = 28,
    MioInGpioGpio29 = 29,
    MioInGpioGpio30 = 30,
    MioInGpioGpio31 = 31,
    MioInI2c0Sda = 32,
    MioInI2c0Scl = 33,
    MioInUart0Rx = 34,
    MioInSpiDeviceTpmCsb = 35,
    MioInFlashCtrlTck = 36,
    MioInFlashCtrlTms = 37,
    MioInFlashCtrlTdi = 38,
    MioInCount = 39
  } mio_in_e;

  typedef enum {
    MioOutGpioGpio0 = 0,
    MioOutGpioGpio1 = 1,
    MioOutGpioGpio2 = 2,
    MioOutGpioGpio3 = 3,
    MioOutGpioGpio4 = 4,
    MioOutGpioGpio5 = 5,
    MioOutGpioGpio6 = 6,
    MioOutGpioGpio7 = 7,
    MioOutGpioGpio8 = 8,
    MioOutGpioGpio9 = 9,
    MioOutGpioGpio10 = 10,
    MioOutGpioGpio11 = 11,
    MioOutGpioGpio12 = 12,
    MioOutGpioGpio13 = 13,
    MioOutGpioGpio14 = 14,
    MioOutGpioGpio15 = 15,
    MioOutGpioGpio16 = 16,
    MioOutGpioGpio17 = 17,
    MioOutGpioGpio18 = 18,
    MioOutGpioGpio19 = 19,
    MioOutGpioGpio20 = 20,
    MioOutGpioGpio21 = 21,
    MioOutGpioGpio22 = 22,
    MioOutGpioGpio23 = 23,
    MioOutGpioGpio24 = 24,
    MioOutGpioGpio25 = 25,
    MioOutGpioGpio26 = 26,
    MioOutGpioGpio27 = 27,
    MioOutGpioGpio28 = 28,
    MioOutGpioGpio29 = 29,
    MioOutGpioGpio30 = 30,
    MioOutGpioGpio31 = 31,
    MioOutI2c0Sda = 32,
    MioOutI2c0Scl = 33,
    MioOutUart0Tx = 34,
    MioOutFlashCtrlTdo = 35,
    MioOutOtpCtrlTest0 = 36,
    MioOutCount = 37
  } mio_out_e;

  // Enumeration for DIO signals, used on both the top and chip-levels.
  typedef enum int unsigned {
    DioSpiHost0Sd0 = 0,
    DioSpiHost0Sd1 = 1,
    DioSpiHost0Sd2 = 2,
    DioSpiHost0Sd3 = 3,
    DioSpiDeviceSd0 = 4,
    DioSpiDeviceSd1 = 5,
    DioSpiDeviceSd2 = 6,
    DioSpiDeviceSd3 = 7,
    DioSpiDeviceSck = 8,
    DioSpiDeviceCsb = 9,
    DioSpiHost0Sck = 10,
    DioSpiHost0Csb = 11,
    DioCount = 12
  } dio_e;

  // Enumeration for the types of pads.
  typedef enum {
    MioPad,
    DioPad
  } pad_type_e;

  // Raw MIO/DIO input array indices on chip-level.
  // TODO: Does not account for target specific stubbed/added pads.
  // Need to make a target-specific package for those.
  typedef enum int unsigned {
    MioPadIoa0 = 0,
    MioPadIoa1 = 1,
    MioPadIoa2 = 2,
    MioPadIoa3 = 3,
    MioPadIoa4 = 4,
    MioPadIoa5 = 5,
    MioPadIoa6 = 6,
    MioPadIoa7 = 7,
    MioPadIoa8 = 8,
    MioPadIob0 = 9,
    MioPadIob1 = 10,
    MioPadIob2 = 11,
    MioPadIob3 = 12,
    MioPadIob4 = 13,
    MioPadIob5 = 14,
    MioPadIob6 = 15,
    MioPadIob7 = 16,
    MioPadIob8 = 17,
    MioPadIob9 = 18,
    MioPadIob10 = 19,
    MioPadIob11 = 20,
    MioPadIob12 = 21,
    MioPadIoc0 = 22,
    MioPadIoc1 = 23,
    MioPadIoc2 = 24,
    MioPadIoc3 = 25,
    MioPadIoc4 = 26,
    MioPadIoc5 = 27,
    MioPadIoc6 = 28,
    MioPadIoc7 = 29,
    MioPadIoc8 = 30,
    MioPadIoc9 = 31,
    MioPadIoc10 = 32,
    MioPadIoc11 = 33,
    MioPadIoc12 = 34,
    MioPadIor0 = 35,
    MioPadIor1 = 36,
    MioPadIor2 = 37,
    MioPadIor3 = 38,
    MioPadIor4 = 39,
    MioPadIor5 = 40,
    MioPadIor6 = 41,
    MioPadIor7 = 42,
    MioPadIor10 = 43,
    MioPadIor11 = 44,
    MioPadIor12 = 45,
    MioPadIor13 = 46,
    MioPadCount
  } mio_pad_e;

  typedef enum int unsigned {
    DioPadPorN = 0,
    DioPadUsbP = 1,
    DioPadUsbN = 2,
    DioPadCc1 = 3,
    DioPadCc2 = 4,
    DioPadFlashTestVolt = 5,
    DioPadFlashTestMode0 = 6,
    DioPadFlashTestMode1 = 7,
    DioPadOtpExtVolt = 8,
    DioPadSpiHostD0 = 9,
    DioPadSpiHostD1 = 10,
    DioPadSpiHostD2 = 11,
    DioPadSpiHostD3 = 12,
    DioPadSpiHostClk = 13,
    DioPadSpiHostCsL = 14,
    DioPadSpiDevD0 = 15,
    DioPadSpiDevD1 = 16,
    DioPadSpiDevD2 = 17,
    DioPadSpiDevD3 = 18,
    DioPadSpiDevClk = 19,
    DioPadSpiDevCsL = 20,
    DioPadCount
  } dio_pad_e;

  // List of peripheral instantiated in this chip.
  typedef enum {
    PeripheralAlertHandler,
    PeripheralAonTimerAon,
    PeripheralAst,
    PeripheralClkmgrAon,
    PeripheralCsrng,
    PeripheralEdn0,
    PeripheralEntropySrc,
    PeripheralErgoCdcBridge0,
    PeripheralErgoCdcBridge1,
    PeripheralErgoCdcBridge2,
    PeripheralErgoCdcBridge3,
    PeripheralErgoCdcBridge4,
    PeripheralErgoCdcBridge5,
    PeripheralErgoCdcBridge6,
    PeripheralErgoCdcBridge7,
    PeripheralErgoCdcBridge8,
    PeripheralErgoCdcHazardGen0,
    PeripheralErgoCdcHazardGen1,
    PeripheralErgoCdcHazardGen2,
    PeripheralErgoCdcHazardGen3,
    PeripheralErgoCdcHazardGen4,
    PeripheralErgoCdcHazardGen5,
    PeripheralErgoCdcHazardGen6,
    PeripheralErgoHoldGen0,
    PeripheralErgoHoldGen1,
    PeripheralErgoHoldGen2,
    PeripheralErgoHoldGen3,
    PeripheralErgoHoldGen4,
    PeripheralErgoHoldGen5,
    PeripheralErgoHoldGen6,
    PeripheralErgoSetupGen0,
    PeripheralErgoSetupGen1,
    PeripheralErgoSetupGen2,
    PeripheralErgoSetupGen3,
    PeripheralErgoSetupGen4,
    PeripheralErgoSetupGen5,
    PeripheralErgoSetupGen6,
    PeripheralErgoSetupGen7,
    PeripheralErgoSetupGen8,
    PeripheralFlashCtrl,
    PeripheralGpio,
    PeripheralI2c0,
    PeripheralKeymgr,
    PeripheralKmac,
    PeripheralLcCtrl,
    PeripheralOtpCtrl,
    PeripheralPinmuxAon,
    PeripheralPwrmgrAon,
    PeripheralRomCtrl,
    PeripheralRstmgrAon,
    PeripheralRvCoreIbex,
    PeripheralRvDm,
    PeripheralRvPlic,
    PeripheralRvTimer,
    PeripheralSpiDevice,
    PeripheralSpiHost0,
    PeripheralSramCtrlMain,
    PeripheralSramCtrlRetAon,
    PeripheralUart0,
    PeripheralCount
  } peripheral_e;

  // TODO: Enumeration for PLIC Interrupt source peripheral.
  // TODO: Enumeration for PLIC Interrupt Ids.

// MACROs for AST analog simulation support
`ifdef ANALOGSIM
  `define INOUT_AI input ast_pkg::awire_t
  `define INOUT_AO output ast_pkg::awire_t
`else
  `define INOUT_AI inout
  `define INOUT_AO inout
`endif

endpackage
