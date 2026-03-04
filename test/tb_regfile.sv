`default_nettype none
`timescale 1ns / 1ps

module tb_regfile ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_regfile);
    #1;
  end

  reg         clk;
  reg  [4:0]  io_readreg1;
  reg  [4:0]  io_readreg2;
  reg  [4:0]  io_writereg;
  reg  [63:0] io_writedata;
  reg         io_wen;
  wire [63:0] io_readdata1;
  wire [63:0] io_readdata2;

  RegisterFile dut (
    .clk          (clk),
    .io_readreg1  (io_readreg1),
    .io_readreg2  (io_readreg2),
    .io_writereg  (io_writereg),
    .io_writedata (io_writedata),
    .io_wen       (io_wen),
    .io_readdata1 (io_readdata1),
    .io_readdata2 (io_readdata2)
  );

endmodule
