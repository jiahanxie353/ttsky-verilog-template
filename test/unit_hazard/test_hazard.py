import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_hazard_no_hazard(dut):
    """Smoke test: no hazard -> no stall, no flush."""
    dut.io_rs1.value = 1
    dut.io_rs2.value = 2
    dut.io_idex_memread.value = 0
    dut.io_idex_rd.value = 0
    dut.io_exmem_taken.value = 0
    await Timer(1, unit="ns")
    assert dut.io_pcstall.value == 0, "pcstall should be 0"
    assert dut.io_if_id_stall.value == 0, "if_id_stall should be 0"
    assert dut.io_id_ex_flush.value == 0, "id_ex_flush should be 0"
    dut._log.info("HazardUnit: no hazard -> no stall/flush")
