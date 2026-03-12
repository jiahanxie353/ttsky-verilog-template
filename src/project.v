/*
 * Copyright (c) 2024 Jiahan Xie
 * SPDX-License-Identifier: Apache-2.0
 */

//========================================================================
// 4-Bit Fixed-Latency Iterative Integer Multiplier
//========================================================================
//
// Pin Mapping (Val/Rdy -> TinyTapeout):
//
//   ui_in[3:0]  = Operand A (4-bit multiplicand)
//   ui_in[7:4]  = Operand B (4-bit multiplier)
//   uio_in[0]   = istream_val  (upstream inputs are valid)
//   uio_in[1]   = ostream_rdy  (downstream ready to take outputs)
//   uo_out[3:0] = Product      (4-bit result)
//   uo_out[7:4] = 0            (unused)
//   uio_out[2]  = istream_rdy  (ready to take inputs from upstream)
//   uio_out[3]  = ostream_val  (outputs to downstream are valid)
//
//========================================================================

`default_nettype none

//------------------------------------------------------------------------
// 2-to-1 Mux
//------------------------------------------------------------------------

module mux2
#(
  parameter p_nbits = 1
)(
  input  logic [p_nbits-1:0] in0, in1,
  input  logic               sel,
  output logic [p_nbits-1:0] out
);

  always_comb begin
    case ( sel )
      1'd0 : out = in0;
      1'd1 : out = in1;
      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule

//------------------------------------------------------------------------
// Positive-edge triggered flip-flop with reset
//------------------------------------------------------------------------

module reset_reg
#(
  parameter p_nbits       = 1,
  parameter p_reset_value = 0
)(
  input  logic               clk,
  input  logic               reset,
  output logic [p_nbits-1:0] q,
  input  logic [p_nbits-1:0] d
);

  always_ff @( posedge clk )
    q <= reset ? p_reset_value : d;

endmodule

//------------------------------------------------------------------------
// Positive-edge triggered flip-flop with enable
//------------------------------------------------------------------------

module en_reg
#(
  parameter p_nbits = 1
)(
  input  logic               clk,
  input  logic               reset,
  output logic [p_nbits-1:0] q,
  input  logic [p_nbits-1:0] d,
  input  logic               en
);

  always_ff @( posedge clk )
    if ( en )
      q <= d;

endmodule

//------------------------------------------------------------------------
// Control Unit
//------------------------------------------------------------------------

module control
(
  input  logic clk,
  input  logic reset,

  input  logic istream_val,
  input  logic ostream_rdy,

  input  logic b_lsb,

  output logic ostream_val,
  output logic istream_rdy,

  output logic a_mux_sel,
  output logic b_mux_sel,
  output logic result_mux_sel,
  output logic result_en,
  output logic add_mux_sel
);

  typedef enum logic [$clog2(3)-1:0] {
    IDLE,
    CALC,
    DONE
  } fsm_state;

  logic [1:0] counter;
  logic [1:0] next_counter;

  fsm_state current_state, next_state;

  always_ff @(posedge clk) begin
    if (reset) begin
      current_state <= IDLE;
      counter <= 2'b00;
    end else begin
      current_state <= next_state;
      counter <= next_counter;
    end
  end

  always_comb begin
    next_state = current_state;
    next_counter = counter;
    case (current_state)
      IDLE: begin
        if (istream_val) begin
          next_state = CALC;
          next_counter = 2'b00;
        end
      end
      CALC: begin
        next_counter = counter + 1;
        if (counter == 2'd3)
          next_state = DONE;
      end
      DONE: begin
        if (ostream_rdy)
          next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  always_comb begin
    a_mux_sel      = 1;
    b_mux_sel      = 1;
    result_mux_sel = 1;
    result_en      = 0;
    add_mux_sel    = 1;
    istream_rdy    = 0;
    ostream_val    = 0;

    case (current_state)
      IDLE: begin
        istream_rdy = 1;
        result_en   = 1;
      end
      CALC: begin
        a_mux_sel      = 0;
        b_mux_sel      = 0;
        result_mux_sel = 0;
        result_en      = 1;
        if (b_lsb == 1)
          add_mux_sel = 0;
      end
      DONE: begin
        ostream_val = 1;
      end
      default: begin end
    endcase
  end

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module datapath
(
  input  logic       clk,
  input  logic       reset,

  input  logic [7:0] istream_msg,

  input  logic       a_mux_sel,
  input  logic       b_mux_sel,
  input  logic       add_mux_sel,
  input  logic       result_mux_sel,
  input  logic       result_en,

  output logic       b_lsb,
  output logic [3:0] ostream_msg
);

  logic [3:0] a;
  logic [3:0] b;

  assign a = istream_msg[3:0];
  assign b = istream_msg[7:4];

  //----------------------------------------------
  // A path (4-bit, shifted left)
  //----------------------------------------------
  logic [3:0] a_shifted, a_mux_out, a_to_shift;

  mux2 #(4) a_mux (
    .in0(a_shifted),
    .in1(a),
    .sel(a_mux_sel),
    .out(a_mux_out)
  );

  reset_reg #(4) a_reg (
    .clk(clk),
    .reset(reset),
    .q(a_to_shift),
    .d(a_mux_out)
  );

  assign a_shifted = a_to_shift << 1;

  //----------------------------------------------
  // B path (4-bit, shifted right)
  //----------------------------------------------
  logic [3:0] b_shifted, b_mux_out, b_to_shift;

  mux2 #(4) b_mux (
    .in0(b_shifted),
    .in1(b),
    .sel(b_mux_sel),
    .out(b_mux_out)
  );

  reset_reg #(4) b_reg (
    .clk(clk),
    .reset(reset),
    .q(b_to_shift),
    .d(b_mux_out)
  );

  assign b_lsb = b_to_shift[0];
  assign b_shifted = b_to_shift >> 1;

  //----------------------------------------------
  // Result path (4-bit)
  //----------------------------------------------
  logic [3:0] add_mux_out, result_mux_out, result_reg_out;

  assign ostream_msg = result_reg_out;

  mux2 #(4) result_mux (
    .in0(add_mux_out),
    .in1(4'd0),
    .sel(result_mux_sel),
    .out(result_mux_out)
  );

  en_reg #(4) result_reg (
    .clk(clk),
    .reset(reset),
    .q(result_reg_out),
    .d(result_mux_out),
    .en(result_en)
  );

  logic [3:0] plus_out;

  assign plus_out = a_to_shift + result_reg_out;

  mux2 #(4) add_mux (
    .in0(plus_out),
    .in1(result_reg_out),
    .sel(add_mux_sel),
    .out(add_mux_out)
  );

endmodule

//========================================================================
// Top-Level: TinyTapeout Wrapper
//========================================================================

module tt_um_mul_jiahanxie353 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Bits 2,3 are outputs (istream_rdy, ostream_val); rest are inputs
  assign uio_oe = 8'b00001100;

  //--------------------------------------------------------------------
  // Input signal mapping
  //--------------------------------------------------------------------
  wire       istream_val = uio_in[0];
  wire       ostream_rdy = uio_in[1];

  // Invert active-low rst_n to active-high reset for internal modules
  wire reset = !rst_n;

  //--------------------------------------------------------------------
  // Control <-> Datapath interconnect
  //--------------------------------------------------------------------
  wire istream_rdy;
  wire ostream_val;

  wire b_lsb;
  wire a_mux_sel;
  wire b_mux_sel;
  wire result_mux_sel;
  wire result_en;
  wire add_mux_sel;

  wire [3:0] product;

  control control_inst (
    .clk            (clk),
    .reset          (reset),
    .istream_val    (istream_val),
    .ostream_rdy    (ostream_rdy),
    .b_lsb          (b_lsb),
    .ostream_val    (ostream_val),
    .istream_rdy    (istream_rdy),
    .a_mux_sel      (a_mux_sel),
    .b_mux_sel      (b_mux_sel),
    .add_mux_sel    (add_mux_sel),
    .result_mux_sel (result_mux_sel),
    .result_en      (result_en)
  );

  datapath datapath_inst (
    .clk            (clk),
    .reset          (reset),
    .istream_msg    (ui_in),
    .a_mux_sel      (a_mux_sel),
    .b_mux_sel      (b_mux_sel),
    .add_mux_sel    (add_mux_sel),
    .result_mux_sel (result_mux_sel),
    .result_en      (result_en),
    .b_lsb          (b_lsb),
    .ostream_msg    (product)
  );

  //--------------------------------------------------------------------
  // Output mapping
  //--------------------------------------------------------------------
  assign uo_out  = {4'd0, product};
  assign uio_out = {4'd0, ostream_val, istream_rdy, 2'd0};

  // Suppress warnings for unused inputs
  wire _unused = &{ena, uio_in[7:2], 1'b0};

endmodule
