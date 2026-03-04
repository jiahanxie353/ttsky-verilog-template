`default_nettype none
`timescale 1ns / 1ps

module tb_adder ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_adder);
    #1;
  end

  reg  [63:0] io_inputx;
  wire [63:0] io_result;

  Adder dut (
    .io_inputx (io_inputx),
    .io_result (io_result)
  );

endmodule
