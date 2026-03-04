module StageReg(
  input         clk,
                rst_n,
  input  [31:0] io_in_instruction,
  input  [63:0] io_in_pc,
  input         io_flush,
                io_valid,
  output [31:0] io_data_instruction,
  output [63:0] io_data_pc
);

  reg [31:0] reg_instruction;
  reg [63:0] reg_pc;
  always @(posedge clk) begin
    if (!rst_n) begin
      reg_instruction <= 32'h0;
      reg_pc <= 64'h0;
    end
    else if (io_flush) begin
      reg_instruction <= 32'h0;
      reg_pc <= 64'h0;
    end
    else if (io_valid) begin
      reg_instruction <= io_in_instruction;
      reg_pc <= io_in_pc;
    end
  end
  assign io_data_instruction = reg_instruction;
  assign io_data_pc = reg_pc;
endmodule

