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


package top_earlgrey_rnd_cnst_pkg;

  ////////////////////////////////////////////
  // kmac
  ////////////////////////////////////////////
  // Compile-time random data for PRNG default seed
  parameter kmac_pkg::lfsr_seed_t RndCnstKmacLfsrSeed = {
    32'hC8A8CC10,
    256'h2F0BDB35_E18D565D_3E4205EF_9ED28A1F_4C6DC8CF_094BCD1B_4B6DE9FF_2511D585
  };

  // Compile-time random permutation for PRNG output
  parameter kmac_pkg::lfsr_perm_t RndCnstKmacLfsrPerm = {
    64'h39248356_66B114D9,
    256'h129E61C9_A212957A_4091AA91_5B03231D_29029AA4_C6E24CE8_57B1AC69_46D4387E,
    256'hB7655BE2_686BAD8B_EC245984_484164C6_5C7A709C_7CE04612_AA222509_2E2741E1,
    256'h4B7C1B27_C265781D_4FDC4C22_DBB98360_F97D9867_204CFE78_0B33C42A_A9C358ED,
    256'h34A89AD1_34C5C4E6_416CC8BC_8009D2EC_AC073BF0_2E30D5C9_02A65D9A_80C0D905,
    256'hE8FBFD57_46D969DA_AF7BEB1A_B0E81397_A00E3E29_6703E810_1699C3DD_C12F8113,
    256'hA4717C5F_C834FC88_AE797DDB_30A8241B_146DA0F2_A6C24B56_D555B89D_5FA7E15B,
    256'h99632945_E6A4A569_0E9B2561_A5F93C9E_AE34DC89_C2A4C2B4_6E662EB9_8DB573D1,
    256'h21825C48_C3D60E8E_0788C898_E266D922_19D223DC_B1FEEAA0_DF718A54_8FDA65E5,
    256'hD43E2A1C_014EB0D0_08A2ED94_8A1AE18F_4ADF568E_9A145030_CD0D8F54_68960E56,
    256'h93A975EE_80586214_0D3CCAE4_429DB56A_5170C984_C69A31DA_AB97CBF4_819FDBE3,
    256'h58E37970_167C18B4_9BB75AD9_85C83BDE_6026DBC4_B1427F41_99C66E66_9E1461E7,
    256'h3B8CC190_BF4F6DE8_A40EAEC3_16F5B034_177BE902_C388B3B1_D05A5787_22CA2525,
    256'hA1B1944F_856118FB_3DA41199_D1BD2004_69142BCE_F07F0DC1_F18310E0_6D273474,
    256'hB85A9A96_09524852_6A914057_5F43AE87_78C8033C_FF830BCA_00F582DD_F28A6C03,
    256'hEA3140DF_24D6F94C_39471D88_F2CD4BA3_A4C82248_17B29220_08EB7B90_780BE6B1,
    256'hDD2F32EC_5A64F94D_9D7BBAFE_30706108_983521C1_1C909BDA_193D8058_2AD8B6B4,
    256'h9284112D_54566789_A8FD2642_7B071D54_20A6DE19_0221BB70_53926169_DE81AF52,
    256'hA1600481_84F8B89D_0E25E50E_690198B6_E8877ED4_18BD7251_13002D38_339DD57E,
    256'h07372B91_656119ED_601DAFA5_ED4258AB_69C14433_17B3212B_BD040315_63958859,
    256'h539B856E_AAD89AA1_7F12A21C_309EBD61_147DAB45_4CD9370B_52258791_856FEB21,
    256'hF461C091_EA19EAA4_EA929892_084ACA24_45B6B1BB_3A087347_B3C8DB08_1CEA61FE,
    256'h58A2B1E4_164224E3_A8A034F1_E3683C5A_1C9BE59E_2DCA8515_C57543B9_090A1510,
    256'h57E5A019_70F58E2A_AFD352E8_D10681C7_89CA52C5_74671C0A_DCC0E9B3_302332C2,
    256'h3110195A_EA1E444E_67668412_71AC2570_64F03C54_703D1C38_54918C13_B9191336,
    256'h2B3AFA90_209FF91C_430DCBB3_7B047A1C_01230570_A881E86F_17D75771_8A6302C7,
    256'hAE370FD0_995ED75C_CB90B401_BCCE168A_35AF2796_654F6E63_9676E077_A3617A24,
    256'h51D8D39E_452AAA0A_5875235B_19F55153_28D016E8_0D2C9562_B500A386_5CA34A16,
    256'h7AD99114_863A527B_A2C2980E_F0B2E5B1_DAD12CA0_21554A99_E7E3496B_BA58E5C5,
    256'hA4B1A6D2_F524B20B_6055B264_2D3826C7_7D84C04B_11C428A1_C9815D06_82C6D071,
    256'hA6237525_43EE5BDB_161D2C02_5CB53C0A_731A1887_E9F459F2_8B028964_5DC49535,
    256'h262349EC_F3288E3B_6347C117_094D7C7C_8A42DEDB_C5D32D07_C8152240_67C1AE1D
  };

  // Compile-time random data for PRNG buffer default seed
  parameter kmac_pkg::buffer_lfsr_seed_t RndCnstKmacBufferLfsrSeed = {
    32'h0E364B0D,
    256'hAC546956_8E661498_FD89197C_CAE8EA08_FF43EFC2_BFB1C6AB_5CC63E6F_4741E80F,
    256'h777CB7FC_05041A1B_896350C9_636D6814_D23E2F5F_F1275EF1_9959AAA8_B6A004D5,
    256'h574984DE_D1CC79BD_6787D666_3AA5E622_682A6525_E083CCDD_BD2A1B00_8057C22C
  };

  // Compile-time random permutation for LFSR Message output
  parameter kmac_pkg::msg_perm_t RndCnstKmacMsgPerm = {
    128'h2D72BB8D_57B89827_2FDBDC65_486AFC1D,
    256'hFA96003B_9192CA37_10C174FA_077F6F23_B0609E73_64140850_F37A6ADA_619F54E2
  };

  ////////////////////////////////////////////
  // otp_ctrl
  ////////////////////////////////////////////
  // Compile-time random bits for initial LFSR seed
  parameter otp_ctrl_pkg::lfsr_seed_t RndCnstOtpCtrlLfsrSeed = {
    40'hF5_65C1B87D
  };

  // Compile-time random permutation for LFSR output
  parameter otp_ctrl_pkg::lfsr_perm_t RndCnstOtpCtrlLfsrPerm = {
    240'h4E74_1985E811_3D58DD50_A0D794C6_C92CE166_2014A408_76008867_1610D7DA
  };

  // Compile-time random permutation for scrambling key/nonce register reset value
  parameter otp_ctrl_pkg::scrmbl_key_init_t RndCnstOtpCtrlScrmblKeyInit = {
    256'h00C81BDE_D7282425_B1BB59B8_01481ED5_793ACCFB_3AF884AE_378405DB_CB5508CD
  };

  ////////////////////////////////////////////
  // lc_ctrl
  ////////////////////////////////////////////
  // Diversification value used for all invalid life cycle states.
  parameter lc_ctrl_pkg::lc_keymgr_div_t RndCnstLcCtrlLcKeymgrDivInvalid = {
    128'h6CD2CE71_5E7CCEB1_BC1C61B3_D27BB8E8
  };

  // Diversification value used for the TEST_UNLOCKED* life cycle states.
  parameter lc_ctrl_pkg::lc_keymgr_div_t RndCnstLcCtrlLcKeymgrDivTestUnlocked = {
    128'h398E880E_CD252956_BA816163_62B27EAF
  };

  // Diversification value used for the DEV life cycle state.
  parameter lc_ctrl_pkg::lc_keymgr_div_t RndCnstLcCtrlLcKeymgrDivDev = {
    128'hB903EC79_BDDF0A4F_7DFF07DB_05DE6391
  };

  // Diversification value used for the PROD/PROD_END life cycle states.
  parameter lc_ctrl_pkg::lc_keymgr_div_t RndCnstLcCtrlLcKeymgrDivProduction = {
    128'h0E4EE4D8_A2C7D402_2F16ED8A_24F80EEB
  };

  // Diversification value used for the RMA life cycle state.
  parameter lc_ctrl_pkg::lc_keymgr_div_t RndCnstLcCtrlLcKeymgrDivRma = {
    128'hCF829983_9C103EAE_3C2F18B4_666B5E59
  };

  // Compile-time random bits used for invalid tokens in the token mux
  parameter lc_ctrl_pkg::lc_token_mux_t RndCnstLcCtrlInvalidTokens = {
    256'hD16C252F_9DB7F094_161D818D_C161FE26_00E05775_DA90406D_9CCEE3E4_3F132C3D,
    256'hA4BAA301_DF91954A_617569CE_FC9183DE_700F5C0C_AE7ED7FE_6C45D153_4FD390C7,
    256'hB068CFE8_968794DE_88E8FF4A_DC3D02EB_FA0A1D5F_AA5EE00C_A5349117_23E1EA06,
    256'h87402A81_6510C535_A8164939_D97DF742_1AD4D2C1_8B270D42_2EC39C41_F727D130
  };

  ////////////////////////////////////////////
  // alert_handler
  ////////////////////////////////////////////
  // Compile-time random bits for initial LFSR seed
  parameter alert_pkg::lfsr_seed_t RndCnstAlertHandlerLfsrSeed = {
    32'hED9B18B9
  };

  // Compile-time random permutation for LFSR output
  parameter alert_pkg::lfsr_perm_t RndCnstAlertHandlerLfsrPerm = {
    160'h599B03F5_20DBAE21_D893D7B3_F9471455_58F2F101
  };

  ////////////////////////////////////////////
  // sram_ctrl_ret_aon
  ////////////////////////////////////////////
  // Compile-time random reset value for SRAM scrambling key.
  parameter otp_ctrl_pkg::sram_key_t RndCnstSramCtrlRetAonSramKey = {
    128'h9339EF14_2E028325_714513BF_DC2A062C
  };

  // Compile-time random reset value for SRAM scrambling nonce.
  parameter otp_ctrl_pkg::sram_nonce_t RndCnstSramCtrlRetAonSramNonce = {
    128'h2EB4ECDC_716A9286_1FF7C06C_6910E727
  };

  // Compile-time random bits for initial LFSR seed
  parameter sram_ctrl_pkg::lfsr_seed_t RndCnstSramCtrlRetAonLfsrSeed = {
    32'hCBED4EE2
  };

  // Compile-time random permutation for LFSR output
  parameter sram_ctrl_pkg::lfsr_perm_t RndCnstSramCtrlRetAonLfsrPerm = {
    160'hD6F238B0_468730F0_C8E9283C_E5FDB522_A88EDE76
  };

  ////////////////////////////////////////////
  // flash_ctrl
  ////////////////////////////////////////////
  // Compile-time random bits for default address key
  parameter flash_ctrl_pkg::flash_key_t RndCnstFlashCtrlAddrKey = {
    128'hD0A3F6C9_B71D03E5_71BEE0E4_7E5B49E8
  };

  // Compile-time random bits for default data key
  parameter flash_ctrl_pkg::flash_key_t RndCnstFlashCtrlDataKey = {
    128'h0E3DA39A_52777DBC_FD9E38D4_D189EC4B
  };

  // Compile-time random bits for default seeds
  parameter flash_ctrl_pkg::all_seeds_t RndCnstFlashCtrlAllSeeds = {
    256'h433E5314_F88C893A_6CB3FD30_A87C3822_5A15108E_992D14BF_1225D4B1_9B23F40E,
    256'h358F1BF4_FE1D5A50_B10232A8_B3C33A60_17B97036_561AA262_31042404_E5EF7464
  };

  // Compile-time random bits for initial LFSR seed
  parameter flash_ctrl_pkg::lfsr_seed_t RndCnstFlashCtrlLfsrSeed = {
    32'h5BE00EA5
  };

  // Compile-time random permutation for LFSR output
  parameter flash_ctrl_pkg::lfsr_perm_t RndCnstFlashCtrlLfsrPerm = {
    160'h1E561393_48919BC4_B94584EB_48BC40F6_2FDFED96
  };

  ////////////////////////////////////////////
  // keymgr
  ////////////////////////////////////////////
  // Compile-time random bits for initial LFSR seed
  parameter keymgr_pkg::lfsr_seed_t RndCnstKeymgrLfsrSeed = {
    64'h67085E49_639BC56B
  };

  // Compile-time random permutation for LFSR output
  parameter keymgr_pkg::lfsr_perm_t RndCnstKeymgrLfsrPerm = {
    128'h909A523E_F30A1CBC_C8AF4AA7_7D1743C3,
    256'hABB85014_176C6FDE_959395C6_DF85EE00_A8F56DB9_984CB785_361CF22B_0DD63680
  };

  // Compile-time random permutation for entropy used in share overriding
  parameter keymgr_pkg::rand_perm_t RndCnstKeymgrRandPerm = {
    160'h6D751452_C95939FC_0613730A_F1F8F9BF_7661024A
  };

  // Compile-time random bits for revision seed
  parameter keymgr_pkg::seed_t RndCnstKeymgrRevisionSeed = {
    256'h2D21F3CD_9D71CA97_90686D8E_E0F7C749_3081881E_AE14520C_C2B37402_1DE436F5
  };

  // Compile-time random bits for creator identity seed
  parameter keymgr_pkg::seed_t RndCnstKeymgrCreatorIdentitySeed = {
    256'h703142E8_3B671A6B_CE2387B9_7B6B2C03_E1AE545B_996ACFDB_3D12929B_942F6D14
  };

  // Compile-time random bits for owner intermediate identity seed
  parameter keymgr_pkg::seed_t RndCnstKeymgrOwnerIntIdentitySeed = {
    256'hC2D1EDD2_4D31EC5D_ABD85825_526737C6_11FA0E7D_754AE64A_354CC7C1_6FA06AE2
  };

  // Compile-time random bits for owner identity seed
  parameter keymgr_pkg::seed_t RndCnstKeymgrOwnerIdentitySeed = {
    256'h8E208C1D_5AFC5F0D_9DE8D61C_C3C920B2_ED6566A1_662940D8_B187A1A3_1A45A09A
  };

  // Compile-time random bits for software generation seed
  parameter keymgr_pkg::seed_t RndCnstKeymgrSoftOutputSeed = {
    256'h6EBDE6CF_840D0216_6D836079_645F80AF_64951722_330EDD3E_68903F68_0EA72174
  };

  // Compile-time random bits for hardware generation seed
  parameter keymgr_pkg::seed_t RndCnstKeymgrHardOutputSeed = {
    256'h50DC1F11_AA9BE9BC_E028ACBB_45FC85DE_AEE9E957_1E205CBA_9A4851B8_9A0AD9B8
  };

  // Compile-time random bits for generation seed when aes destination selected
  parameter keymgr_pkg::seed_t RndCnstKeymgrAesSeed = {
    256'hE60F7B4B_CF8ACBC5_840E79CB_084D95CA_06120352_218C90DF_AB74299E_7882F53F
  };

  // Compile-time random bits for generation seed when kmac destination selected
  parameter keymgr_pkg::seed_t RndCnstKeymgrKmacSeed = {
    256'h007A8AC1_BC2FDEBB_DB82764E_00B66018_476EC7E9_AE86D24F_AC08B704_A4D6DF17
  };

  // Compile-time random bits for generation seed when otbn destination selected
  parameter keymgr_pkg::seed_t RndCnstKeymgrOtbnSeed = {
    256'h92AD00E1_6CC7C015_D8529055_3843B5B6_AF2BF8AC_41CB2B75_E1506639_338BE5DC
  };

  // Compile-time random bits for generation seed when no CDI is selected
  parameter keymgr_pkg::seed_t RndCnstKeymgrCdi = {
    256'h0FA4BDDB_E5F3D5A9_F9386DA8_4DDB0C6E_BD1E7706_7A438F6C_B7F937D1_E60908AB
  };

  // Compile-time random bits for generation seed when no destination selected
  parameter keymgr_pkg::seed_t RndCnstKeymgrNoneSeed = {
    256'hB1B5FA56_226EF0EE_D9D76B62_E7B4E446_6B9601DB_B4592FF1_9842D516_06FE22B8
  };

  ////////////////////////////////////////////
  // csrng
  ////////////////////////////////////////////
  // Compile-time random bits for csrng state group diversification value
  parameter csrng_pkg::cs_keymgr_div_t RndCnstCsrngCsKeymgrDivNonProduction = {
    128'hED0E3F50_759650EF_701A4E6E_4916EEE5,
    256'h6EF868E4_092F9516_CC8B20BE_D74B6A71_5B33CADB_9092B112_5746C49F_15A16A2A
  };

  // Compile-time random bits for csrng state group diversification value
  parameter csrng_pkg::cs_keymgr_div_t RndCnstCsrngCsKeymgrDivProduction = {
    128'h1FD01F8E_09D92DD1_3E029879_9D91C54B,
    256'hFD2A51F4_5AADF344_C262BB0A_BDE9B240_D763DA6C_4250BA5A_44A7D4F4_D7F99B4A
  };

  ////////////////////////////////////////////
  // sram_ctrl_main
  ////////////////////////////////////////////
  // Compile-time random reset value for SRAM scrambling key.
  parameter otp_ctrl_pkg::sram_key_t RndCnstSramCtrlMainSramKey = {
    128'h6480DA2D_53E7CA15_201A8F56_53001011
  };

  // Compile-time random reset value for SRAM scrambling nonce.
  parameter otp_ctrl_pkg::sram_nonce_t RndCnstSramCtrlMainSramNonce = {
    128'h7F58C9E9_946C1118_0407FEB4_710F404E
  };

  // Compile-time random bits for initial LFSR seed
  parameter sram_ctrl_pkg::lfsr_seed_t RndCnstSramCtrlMainLfsrSeed = {
    32'h6E4FACE5
  };

  // Compile-time random permutation for LFSR output
  parameter sram_ctrl_pkg::lfsr_perm_t RndCnstSramCtrlMainLfsrPerm = {
    160'h0E35DA19_444B219F_89778DBC_879DA0E3_ABB19653
  };

  ////////////////////////////////////////////
  // rom_ctrl
  ////////////////////////////////////////////
  // Fixed nonce used for address / data scrambling
  parameter bit [63:0] RndCnstRomCtrlScrNonce = {
    64'hEEC6BA04_86F07CFF
  };

  // Randomised constant used as a scrambling key for ROM data
  parameter bit [127:0] RndCnstRomCtrlScrKey = {
    128'hAF7B8B92_13BD8DC7_B927797C_09DFEAF1
  };

  ////////////////////////////////////////////
  // rv_core_ibex
  ////////////////////////////////////////////
  // Default seed of the PRNG used for random instructions.
  parameter ibex_pkg::lfsr_seed_t RndCnstRvCoreIbexLfsrSeed = {
    32'h272B92AB
  };

  // Permutation applied to the LFSR of the PRNG used for random instructions.
  parameter ibex_pkg::lfsr_perm_t RndCnstRvCoreIbexLfsrPerm = {
    160'hEB1F416A_F1312685_D732FEE0_E4D8BC1F_8EA68038
  };

  // Default icache scrambling key
  parameter logic [ibex_pkg::SCRAMBLE_KEY_W-1:0] RndCnstRvCoreIbexIbexKeyDefault = {
    128'hAAE70F22_AAF748B5_7C320264_E157E2C7
  };

  // Default icache scrambling nonce
  parameter logic [ibex_pkg::SCRAMBLE_NONCE_W-1:0] RndCnstRvCoreIbexIbexNonceDefault = {
    64'h4A280332_61EE6CEC
  };

endpackage : top_earlgrey_rnd_cnst_pkg
