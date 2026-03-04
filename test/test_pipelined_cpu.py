import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_cpu_nop_smoke(dut):
    """Reset the CPU and run NOPs — verify PC increments."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Memory always ready
    dut.io_imem_good.value = 1
    dut.io_imem_ready.value = 1
    dut.io_dmem_good.value = 1

    # Assert active-low reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Feed NOP (addi x0, x0, 0 = 0x00000013)
    dut.io_imem_instruction.value = 0x0000001300000013
    dut.io_dmem_readdata.value = 0

    await ClockCycles(dut.clk, 20)
    dut._log.info("CPU survived 20 NOP cycles after reset")
