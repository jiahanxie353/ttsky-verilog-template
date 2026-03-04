# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.binary import BinaryValue, BinaryRepresentation
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_pipelined_cpu(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Memory always ready
    dut.io_imem_good.value = 1
    dut.io_imem_ready.value = 1
    dut.io_dmem_good.value = 1

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test running NOPs")

    # Default: feed NOP (addi x0, x0, 0)
    addi_nop_bv = BinaryValue(value="11011", n_bits=64, binaryRepresentation=BinaryRepresentation.UNSIGNED)
    dut.io_imem_instruction.value = addi_nop_bv
    dut.io_dmem_readdata.value = 0

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 20)

    dut._log.info("CPU survived 20 NOP cycles after reset")
