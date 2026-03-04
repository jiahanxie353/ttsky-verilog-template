`default_nettype none
`timescale 1ns / 1ps

module tb_immgen ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_immgen);
    #1;
  end

  reg  [63:0] io_instruction;
  wire [63:0] io_sextImm;

  ImmediateGenerator dut (
    .io_instruction (io_instruction),
    .io_sextImm     (io_sextImm)
  );

endmodule
