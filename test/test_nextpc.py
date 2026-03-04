import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_nextpc_no_branch(dut):
    """Smoke test: no branch/jump -> nextpc = pc + 4."""
    dut.io_branch.value = 0
    dut.io_jumptype.value = 0
    dut.io_inputx.value = 0
    dut.io_inputy.value = 0
    dut.io_funct3.value = 0
    dut.io_pc.value = 0x1000
    dut.io_imm.value = 0
    await Timer(1, unit="ns")
    nextpc = dut.io_nextpc.value.to_unsigned()
    assert nextpc == 0x1004, f"Expected 0x1004, got {nextpc:#x}"
    assert dut.io_taken.value == 0, "taken should be 0"
    dut._log.info(f"NextPC no-branch: pc=0x1000 -> nextpc={nextpc:#x}")
