import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_forwarding_no_hazard(dut):
    """Smoke test: no forwarding when rd=0 or no reg-write."""
    dut.io_rs1.value = 1
    dut.io_rs2.value = 2
    dut.io_exmemrd.value = 0
    dut.io_exmemrw.value = 0
    dut.io_memwbrd.value = 0
    dut.io_memwbrw.value = 0
    await Timer(1, unit="ns")
    assert dut.io_forwardA.value == 0, f"forwardA should be 0, got {dut.io_forwardA.value}"
    assert dut.io_forwardB.value == 0, f"forwardB should be 0, got {dut.io_forwardB.value}"
    dut._log.info("ForwardingUnit: no hazard -> forwardA=0, forwardB=0")
