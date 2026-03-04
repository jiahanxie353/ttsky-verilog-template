import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_alu_add(dut):
    """Smoke test: ALU addition (operation=0b00111, 3+4=7)."""
    dut.io_operation.value = 0b00111  # ADD
    dut.io_inputx.value = 3
    dut.io_inputy.value = 4
    await Timer(1, unit="ns")
    result = dut.io_result.value.to_unsigned()
    assert result == 7, f"Expected 7, got {result}"
    dut._log.info(f"ALU ADD: 3 + 4 = {result}")
