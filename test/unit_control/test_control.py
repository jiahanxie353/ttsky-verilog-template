import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_control_rtype(dut):
    """Smoke test: R-type opcode (0x33) sets aluop=1, regwrite=1."""
    dut.io_opcode.value = 0x33  # R-type
    await Timer(1, unit="ns")
    assert dut.io_aluop.value == 1, "R-type should set aluop=1"
    assert dut.io_regwrite.value == 1, "R-type should set regwrite=1"
    dut._log.info("Control R-type: aluop=1, regwrite=1")
