`default_nettype none
`timescale 1ns / 1ps

module tb_alucontrol ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_alucontrol);
    #1;
  end

  reg        io_aluop;
  reg        io_itype;
  reg  [6:0] io_funct7;
  reg  [2:0] io_funct3;
  reg        io_wordinst;
  wire [4:0] io_operation;

  ALUControl dut (
    .io_aluop     (io_aluop),
    .io_itype     (io_itype),
    .io_funct7    (io_funct7),
    .io_funct3    (io_funct3),
    .io_wordinst  (io_wordinst),
    .io_operation (io_operation)
  );

endmodule
