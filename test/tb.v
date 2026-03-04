`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Replace tt_um_example with your module name:
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

    PipelinedCPU dut (
      .clk                (clk),
      .reset              (reset),
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

  PipelinedCPU pipelined_cpu_i (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule
