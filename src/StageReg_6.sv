module StageReg_6(
  input  clk,
         rst_n,
         io_in_wb_ctrl_toreg,
         io_in_wb_ctrl_regwrite,
  output io_data_wb_ctrl_toreg,
         io_data_wb_ctrl_regwrite
);

  reg reg_wb_ctrl_toreg;
  reg reg_wb_ctrl_regwrite;
  always @(posedge clk) begin
    if (!rst_n) begin
      reg_wb_ctrl_toreg <= 1'h0;
      reg_wb_ctrl_regwrite <= 1'h0;
    end
    else begin
      reg_wb_ctrl_toreg <= io_in_wb_ctrl_toreg;
      reg_wb_ctrl_regwrite <= io_in_wb_ctrl_regwrite;
    end
  end // always @(posedge)
  assign io_data_wb_ctrl_toreg = reg_wb_ctrl_toreg;
  assign io_data_wb_ctrl_regwrite = reg_wb_ctrl_regwrite;
endmodule

