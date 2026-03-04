`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  reg clk;
  reg rst_n;

  // Instruction memory interface
  wire [63:0] io_imem_address;
  wire        io_imem_valid;
  reg         io_imem_good;
  reg  [63:0] io_imem_instruction;
  reg         io_imem_ready;

  // Data memory interface
  wire [63:0] io_dmem_address;
  wire        io_dmem_valid;
  wire [63:0] io_dmem_writedata;
  wire        io_dmem_memread;
  wire        io_dmem_memwrite;
  wire [1:0]  io_dmem_maskmode;
  wire        io_dmem_sext;
  reg         io_dmem_good;
  reg  [63:0] io_dmem_readdata;

  tt_um_pipelined_dino_jiahanxie353 dut (
    .clk                (clk),
    .rst_n              (rst_n),
    .io_imem_address    (io_imem_address),
    .io_imem_valid      (io_imem_valid),
    .io_imem_good       (io_imem_good),
    .io_imem_instruction(io_imem_instruction),
    .io_imem_ready      (io_imem_ready),
    .io_dmem_address    (io_dmem_address),
    .io_dmem_valid      (io_dmem_valid),
    .io_dmem_writedata  (io_dmem_writedata),
    .io_dmem_memread    (io_dmem_memread),
    .io_dmem_memwrite   (io_dmem_memwrite),
    .io_dmem_maskmode   (io_dmem_maskmode),
    .io_dmem_sext       (io_dmem_sext),
    .io_dmem_good       (io_dmem_good),
    .io_dmem_readdata   (io_dmem_readdata)
  );

endmodule
