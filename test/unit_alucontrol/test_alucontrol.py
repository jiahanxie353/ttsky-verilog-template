import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_alucontrol_add(dut):
    """Smoke test: R-type ADD decodes to operation=0b00111."""
    dut.io_aluop.value = 1
    dut.io_itype.value = 0
    dut.io_funct7.value = 0x00
    dut.io_funct3.value = 0b000
    dut.io_wordinst.value = 0
    await Timer(1, unit="ns")
    op = dut.io_operation.value.to_unsigned()
    assert op == 0b00111, f"Expected 0b00111 (ADD), got {op:#07b}"
    dut._log.info(f"ALUControl R-type ADD -> operation={op:#07b}")
