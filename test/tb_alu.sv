`default_nettype none
`timescale 1ns / 1ps

module tb_alu ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_alu);
    #1;
  end

  reg  [4:0]  io_operation;
  reg  [63:0] io_inputx;
  reg  [63:0] io_inputy;
  wire [63:0] io_result;

  ALU dut (
    .io_operation (io_operation),
    .io_inputx    (io_inputx),
    .io_inputy    (io_inputy),
    .io_result    (io_result)
  );

endmodule
