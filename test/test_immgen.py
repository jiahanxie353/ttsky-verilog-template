import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_immgen_itype(dut):
    """Smoke test: I-type addi x1, x0, 42 -> sextImm = 42."""
    # addi x1, x0, 42 = imm[11:0]=42, rs1=0, funct3=000, rd=1, opcode=0010011
    # 0x02A00093
    dut.io_instruction.value = 0x02A00093
    await Timer(1, unit="ns")
    imm = dut.io_sextImm.value.to_unsigned()
    assert imm == 42, f"Expected 42, got {imm}"
    dut._log.info(f"ImmGen I-type: addi x1,x0,42 -> sextImm={imm}")
