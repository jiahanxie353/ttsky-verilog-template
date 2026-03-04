# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info
#
# Usage:
#   make                — run integration test (default, for CI)
#   make test-alu       — run a single unit test
#   make unit           — run all unit tests
#   make clean          — remove build artifacts

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD = sim_build/rtl/$(TOPLEVEL)
VERILOG_SOURCES += $(wildcard $(SRC_DIR)/*.sv) $(wildcard $(SRC_DIR)/*.v)

else

# Gate level simulation:
SIM_BUILD = sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# SystemVerilog support and include path
COMPILE_ARGS += -g2012
COMPILE_ARGS += -I$(SRC_DIR)

# Include all testbench sources
VERILOG_SOURCES += $(PWD)/tb.v
VERILOG_SOURCES += $(wildcard $(PWD)/tb_*.sv)

# Default: integration test
TOPLEVEL ?= tb
COCOTB_TEST_MODULES ?= test_pipelined_cpu

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

# --- Convenience targets for unit tests ---

UNIT_TESTS = test-alu test-alucontrol test-control test-adder \
             test-nextpc test-immgen test-forwarding test-hazard test-regfile

.PHONY: unit $(UNIT_TESTS)

unit: $(UNIT_TESTS)

test-alu:
	$(MAKE) TOPLEVEL=tb_alu COCOTB_TEST_MODULES=test_alu

test-alucontrol:
	$(MAKE) TOPLEVEL=tb_alucontrol COCOTB_TEST_MODULES=test_alucontrol

test-control:
	$(MAKE) TOPLEVEL=tb_control COCOTB_TEST_MODULES=test_control

test-adder:
	$(MAKE) TOPLEVEL=tb_adder COCOTB_TEST_MODULES=test_adder

test-nextpc:
	$(MAKE) TOPLEVEL=tb_nextpc COCOTB_TEST_MODULES=test_nextpc

test-immgen:
	$(MAKE) TOPLEVEL=tb_immgen COCOTB_TEST_MODULES=test_immgen

test-forwarding:
	$(MAKE) TOPLEVEL=tb_forwarding COCOTB_TEST_MODULES=test_forwarding

test-hazard:
	$(MAKE) TOPLEVEL=tb_hazard COCOTB_TEST_MODULES=test_hazard

test-regfile:
	$(MAKE) TOPLEVEL=tb_regfile COCOTB_TEST_MODULES=test_regfile
