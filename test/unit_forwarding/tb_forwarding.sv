`default_nettype none
`timescale 1ns / 1ps

module tb_forwarding ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_forwarding);
    #1;
  end

  reg  [4:0] io_rs1;
  reg  [4:0] io_rs2;
  reg  [4:0] io_exmemrd;
  reg        io_exmemrw;
  reg  [4:0] io_memwbrd;
  reg        io_memwbrw;
  wire [1:0] io_forwardA;
  wire [1:0] io_forwardB;

  ForwardingUnit dut (
    .io_rs1      (io_rs1),
    .io_rs2      (io_rs2),
    .io_exmemrd  (io_exmemrd),
    .io_exmemrw  (io_exmemrw),
    .io_memwbrd  (io_memwbrd),
    .io_memwbrw  (io_memwbrw),
    .io_forwardA (io_forwardA),
    .io_forwardB (io_forwardB)
  );

endmodule
