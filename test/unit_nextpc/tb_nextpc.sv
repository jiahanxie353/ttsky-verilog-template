`default_nettype none
`timescale 1ns / 1ps

module tb_nextpc ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_nextpc);
    #1;
  end

  reg         io_branch;
  reg  [1:0]  io_jumptype;
  reg  [63:0] io_inputx;
  reg  [63:0] io_inputy;
  reg  [2:0]  io_funct3;
  reg  [63:0] io_pc;
  reg  [63:0] io_imm;
  wire [63:0] io_nextpc;
  wire        io_taken;

  NextPC dut (
    .io_branch   (io_branch),
    .io_jumptype (io_jumptype),
    .io_inputx   (io_inputx),
    .io_inputy   (io_inputy),
    .io_funct3   (io_funct3),
    .io_pc       (io_pc),
    .io_imm      (io_imm),
    .io_nextpc   (io_nextpc),
    .io_taken    (io_taken)
  );

endmodule
