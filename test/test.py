# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset(dut):
    dut._log.info("Reset")

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Reset successful")


async def multiply(dut, a, b):
    """Perform a single multiply transaction via val/rdy handshake.

    Pin mapping:
      ui_in[3:0]  = operand A
      ui_in[7:4]  = operand B
      uio_in[0]   = istream_val
      uio_in[1]   = ostream_rdy
      uio_out[2]  = istream_rdy
      uio_out[3]  = ostream_val
      uo_out[3:0] = product
    """
    # Wait until istream_rdy is high
    for _ in range(20):
        if dut.uio_out.value[2] == 1:
            break
        await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value[2] == 1, "istream_rdy never went high"

    # Mask to 4 bits so negative Python ints map to 2's complement
    a_u = a & 0xF
    b_u = b & 0xF

    # Drive operands and assert istream_val
    dut.ui_in.value = (b_u << 4) | a_u
    dut.uio_in.value = 0x01  # manually drive istream_val = 1, ostream_rdy = 0
    await ClockCycles(dut.clk, 1)

    # Deassert istream_val, wait for computation (4 cycles)
    dut.uio_in.value = 0x00
    await ClockCycles(dut.clk, 4)

    # Wait until ostream_val is high
    for _ in range(20):
        if dut.uio_out.value[3] == 1:
            break
        await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value[3] == 1, "ostream_val never went high"

    # Read the product
    result = dut.uo_out.value.integer & 0x0F

    # Complete the transaction
    dut.uio_in.value = 0x02  # manually drive ostream_rdy = 1
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0x00
    await ClockCycles(dut.clk, 1)

    return result


@cocotb.test()
async def test_reset(dut):
    dut._log.info("Reset test start")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await reset(dut)

    # After reset: IDLE state, istream_rdy=1, ostream_val=0
    assert dut.uio_out.value[2] == 1, "Expected istream_rdy (uio_out[2]) high after reset"
    assert dut.uio_out.value[3] == 0, "Expected ostream_val (uio_out[3]) low after reset"

    dut._log.info("Reset test passed")


########################################## 
### Basic tests
########################################## 

@cocotb.test()
async def test_mul_0x0(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, 0, 0)
    assert result == 0, f"0 * 0: expected 0, got {result}"
    dut._log.info("PASS: 0 * 0 = 0")


@cocotb.test()
async def test_mul_1x1(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, 1, 1)
    assert result == 1, f"1 * 1: expected 1, got {result}"
    dut._log.info("PASS: 1 * 1 = 1")


@cocotb.test()
async def test_mul_2x3(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, 2, 3)
    assert result == 6, f"2 * 3: expected 6, got {result}"
    dut._log.info("PASS: 2 * 3 = 6")

##########################################
###  Negative numbers
###  (4-bit 2's complement inputs,
###   result is unsigned mod 16)
##########################################

@cocotb.test()
async def test_mul_0x_neg1(dut):
    """Test 0 * -1 = 0  (0x0 * 0xF = 0)"""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, 0, -1)
    assert result == 0, f"0 * -1: expected 0, got {result}"
    dut._log.info("PASS: 0 * -1 = 0")


@cocotb.test()
async def test_mul_neg1x_neg2(dut):
    """Test -1 * -2 = 2  (0xF * 0xE = 210, mod 16 = 2)"""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, -1, -2)
    assert result == 2, f"-1 * -2: expected 2, got {result}"
    dut._log.info("PASS: -1 * -2 = 2")


@cocotb.test()
async def test_mul_neg2x5(dut):
    """Test -2 * 5 = 6  (0xE * 0x5 = 70, mod 16 = 6)"""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, -2, 5)
    assert result == 6, f"-2 * 5: expected 6, got {result}"
    dut._log.info("PASS: -2 * 5 = 6")

##########################################
###  Edge cases
##########################################

@cocotb.test()
async def test_mul_15x15(dut):
    """Test all 1's: 0xF * 0xF = 225, mod 16 = 1"""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, 0xF, 0xF)
    assert result == 1, f"15 * 15: expected 1, got {result}"
    dut._log.info("PASS: 0xF * 0xF = 1 (225 mod 16)")


@cocotb.test()
async def test_mul_3x5(dut):
    """Test max non-overflow: 3 * 5 = 15 = 0xF (exactly 1111)"""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, 3, 5)
    assert result == 15, f"3 * 5: expected 15, got {result}"
    dut._log.info("PASS: 3 * 5 = 15 (0xF, no overflow)")


@cocotb.test()
async def test_mul_2x8(dut):
    """Test exact overflow: 2 * 8 = 16 = 0x10, truncates to 0"""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    result = await multiply(dut, 2, 8)
    assert result == 0, f"2 * 8: expected 0, got {result}"
    dut._log.info("PASS: 2 * 8 = 0 (16 mod 16, overflow truncation)")

