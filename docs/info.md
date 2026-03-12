<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a 4-bit fixed-latency iterative integer multiplier that computes `A * B` using the shift-and-add algorithm. It takes two 4-bit unsigned operands and produces a 4-bit product.

The design is split into a control unit (FSM) and a datapath:

- Control unit: A 3-state FSM (IDLE -> CALC -> DONE) with a 2-bit counter. In the CALC state, the FSM iterates for exactly 4 clock cycles (one per bit of B). The FSM uses val/rdy handshaking for flow control.
- Datapath: Contains shift registers for operands A (left shift) and B (right shift), an accumulator for the running result, and an adder. On each CALC cycle, if the LSB of B is 1, the current value of A is added to the result accumulator.

The multiplier has a fixed latency of 4 clock cycles regardless of operand values.

## How to test

The multiplier uses a val/rdy handshake protocol on the bidirectional IO pins:

1. Assert reset: Drive `rst_n` low for at least one clock cycle, then release high.
2. Send operands: Place operand A on `ui_in[3:0]` and operand B on `ui_in[7:4]`. Assert `istream_val` (`uio_in[0]`) high. Wait for `istream_rdy` (`uio_out[2]`) to be high — the handshake fires when both val and rdy are high on the same rising clock edge.
3. Wait for result: After 4 computation cycles, the FSM enters the DONE state and asserts `ostream_val` (`uio_out[3]`).
4. Read the product: Assert `ostream_rdy` (`uio_in[1]`) high. When both `ostream_val` and `ostream_rdy` are high, read the 4-bit product from `uo_out[3:0]`. The multiplier returns to IDLE and is ready for the next transaction.

Note: The product is the lower 4 bits of the full 8-bit result (`A * B mod 16`).

## External hardware

No external hardware required.
