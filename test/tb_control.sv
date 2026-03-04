`default_nettype none
`timescale 1ns / 1ps

module tb_control ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_control);
    #1;
  end

  reg  [6:0] io_opcode;
  wire       io_itype;
  wire       io_aluop;
  wire       io_src1;
  wire [1:0] io_src2;
  wire       io_branch;
  wire [1:0] io_jumptype;
  wire       io_resultselect;
  wire [1:0] io_memop;
  wire       io_toreg;
  wire       io_regwrite;
  wire       io_wordinst;

  Control dut (
    .io_opcode       (io_opcode),
    .io_itype        (io_itype),
    .io_aluop        (io_aluop),
    .io_src1         (io_src1),
    .io_src2         (io_src2),
    .io_branch       (io_branch),
    .io_jumptype     (io_jumptype),
    .io_resultselect (io_resultselect),
    .io_memop        (io_memop),
    .io_toreg        (io_toreg),
    .io_regwrite     (io_regwrite),
    .io_wordinst     (io_wordinst)
  );

endmodule
