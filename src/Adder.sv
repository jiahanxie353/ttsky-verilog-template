module Adder(
  input  [63:0] io_inputx,
  output [63:0] io_result
);

  assign io_result = io_inputx + 64'h4;
endmodule

