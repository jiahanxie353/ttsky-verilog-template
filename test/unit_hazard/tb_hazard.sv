`default_nettype none
`timescale 1ns / 1ps

module tb_hazard ();

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_hazard);
    #1;
  end

  reg  [4:0] io_rs1;
  reg  [4:0] io_rs2;
  reg        io_idex_memread;
  reg  [4:0] io_idex_rd;
  reg        io_exmem_taken;
  wire       io_pcfromtaken;
  wire       io_pcstall;
  wire       io_if_id_stall;
  wire       io_id_ex_flush;
  wire       io_ex_mem_flush;
  wire       io_if_id_flush;

  HazardUnit dut (
    .io_rs1          (io_rs1),
    .io_rs2          (io_rs2),
    .io_idex_memread (io_idex_memread),
    .io_idex_rd      (io_idex_rd),
    .io_exmem_taken  (io_exmem_taken),
    .io_pcfromtaken  (io_pcfromtaken),
    .io_pcstall      (io_pcstall),
    .io_if_id_stall  (io_if_id_stall),
    .io_id_ex_flush  (io_id_ex_flush),
    .io_ex_mem_flush (io_ex_mem_flush),
    .io_if_id_flush  (io_if_id_flush)
  );

endmodule
