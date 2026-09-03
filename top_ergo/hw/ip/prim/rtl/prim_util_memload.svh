// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Memory loader for simulation
 *
 * Include this file in a memory primitive to load a memory array from
 * simulation.
 *
 * Requirements:
 * - A memory array named `mem`.
 * - A parameter `Width` giving the memory width (word size) in bit.
 * - A parameter `Depth` giving the memory depth in words.
 * - A parameter `MemInitFile` with a file path of a VMEM file to be loaded into
 *   the memory if not empty.
 *
 * Note this works with memories up to a maximum width of 312 bits. Should this maximum width be
 * increased all of the `simutil_set_mem` and `simutil_get_mem` call sites must be found (e.g. using
 * git grep) and adjusted appropriately.
 */

`ifndef SYNTHESIS
  // Task for loading 'mem' with SystemVerilog system task $readmemh()
  export "DPI-C" task simutil_memload;

  task simutil_memload;
    input string file;
    $readmemh(file, mem);
  endtask

  // Function for setting a specific element in |mem|
  // Returns 1 (true) for success, 0 (false) for errors.
  export "DPI-C" function simutil_set_mem;

  function int simutil_set_mem(input int index, input bit [311:0] val);
    int valid;
    valid = Width > 312 || index >= Depth ? 0 : 1;
    if (valid == 1) mem[index] = val[Width-1:0];
    return valid;
  endfunction

  // Function for getting a specific element in |mem|
  export "DPI-C" function simutil_get_mem;

  function int simutil_get_mem(input int index, output bit [311:0] val);
    int valid;
    valid = Width > 312 || index >= Depth ? 0 : 1;
    if (valid == 1) begin
      val = 0;
      val[Width-1:0] = mem[index];
    end
    return valid;
  endfunction

  // Sim-only debug/init helpers: hierarchical-path printing and file-based memory
  // initialization. Not synthesizable ($value$plusargs, $readmemh) -- this trailing block used
  // to sit outside the `ifndef SYNTHESIS guard above, which prim_generic_ram_1p/1r1w/2p never hit
  // since their whole body (including this include) is already excluded via
  // `ifndef SYNTHESIS_MEMORY_BLACK_BOXING, but prim_generic_rom.sv has no such wrapper and always
  // includes this file.
  initial begin
    logic show_mem_paths;

    // Print the hierarchical path to the memory to help make formal connectivity checks easy.
    void'($value$plusargs("show_mem_paths=%0b", show_mem_paths));
    if (show_mem_paths) $display("%m");

    if (MemInitFile != "") begin : gen_meminit
        $display("Initializing memory %m from file '%s'.", MemInitFile);
        $readmemh(MemInitFile, mem);
    end
  end
`endif
