<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

DinoPipelinedCPU is a classic five-stage pipelined RISC-V CPU implementing the RV64I base integer instruction set, based on the design from Patterson and Hennessy's *Computer Organization and Design*. The five pipeline stages are:

1. **IF (Instruction Fetch)** — Reads the next instruction from memory via the SPI interface and increments the PC.
2. **ID (Instruction Decode)** — Decodes the instruction, reads the register file, generates the immediate value, and produces control signals.
3. **EX (Execute)** — Performs ALU operations, computes branch/jump targets, and resolves forwarding.
4. **MEM (Memory Access)** — Reads from or writes to data memory via the SPI interface.
5. **WB (Write Back)** — Writes the result back to the register file.

The pipeline includes a **forwarding unit** to resolve data hazards by bypassing results from later stages, and a **hazard detection unit** that inserts stalls for load-use hazards and flushes the pipeline on taken branches and jumps.

The CPU communicates with external memory (provided by the RP2040 on the TinyTapeout demo board running spi-ram-emu) over an SPI interface on the bidirectional pins. A UART interface is available for serial console interaction.

## How to test

### Simulation

The test infrastructure uses [cocotb](https://www.cocotb.org/) (v2.0) with Icarus Verilog. All tests live in the `test/` directory and are driven by a single `Makefile`.

**Integration test** — The default `make` target runs a full-CPU integration test (`tb.v` + `test_pipelined_cpu.py`). It instantiates the `PipelinedCPU`, asserts the active-low reset, feeds NOP instructions via the instruction memory interface, and verifies the CPU survives multiple clock cycles. This also supports gate-level simulation with `make GATES=yes` for post-synthesis verification.

**Unit tests** — Each pipeline component has its own testbench (`tb_<module>.sv`) and cocotb test (`test_<module>.py`). Available targets:

- `make test-alu` — ALU operations
- `make test-alucontrol` — ALU control signal decoding
- `make test-control` — Main control unit
- `make test-adder` — PC+4 adder
- `make test-nextpc` — Next PC / branch target logic
- `make test-immgen` — Immediate value generator
- `make test-forwarding` — Data forwarding unit
- `make test-hazard` — Hazard detection unit
- `make test-regfile` — 32x64-bit register file

Run `make unit` to execute all unit tests.

### Hardware

1. Connect the TinyTapeout demo board via USB. The RP2040 provides both SPI RAM emulation and UART-to-USB bridging.
2. Configure the RP2040 to run [spi-ram-emu](https://github.com/MichaelBell/spi-ram-emu) and load a RISC-V binary into the emulated memory.

## External hardware

- TinyTapeout demo board with RP2040 running [spi-ram-emu](https://github.com/MichaelBell/spi-ram-emu) for SPI RAM on `uio[0:3]`
- USB cable for UART serial console via RP2040 on `ui[3]` (RX) / `uo[4]` (TX)
