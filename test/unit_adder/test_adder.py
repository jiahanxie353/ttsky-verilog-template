import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_adder_plus4(dut):
    """Smoke test: Adder adds 4 to input (0 + 4 = 4)."""
    dut.io_inputx.value = 0
    await Timer(1, unit="ns")
    result = dut.io_result.value.to_unsigned()
    assert result == 4, f"Expected 4, got {result}"
    dut._log.info(f"Adder: 0 + 4 = {result}")
