import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


@cocotb.test()
async def test_regfile_write_read(dut):
    """Smoke test: write 0xDEAD to reg 1, then read it back."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Write 0xDEAD to register 1
    dut.io_wen.value = 1
    dut.io_writereg.value = 1
    dut.io_writedata.value = 0xDEAD
    dut.io_readreg1.value = 1
    dut.io_readreg2.value = 0
    await ClockCycles(dut.clk, 1)

    # Stop writing, read back
    dut.io_wen.value = 0
    await Timer(1, unit="ns")
    rd1 = dut.io_readdata1.value.to_unsigned()
    assert rd1 == 0xDEAD, f"Expected 0xDEAD, got {rd1:#x}"
    dut._log.info(f"RegisterFile: wrote 0xDEAD to r1, read back {rd1:#x}")
