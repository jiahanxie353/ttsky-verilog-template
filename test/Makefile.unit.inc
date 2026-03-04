# Shared boilerplate for unit tests — include from each unit_*/Makefile
# Each unit Makefile must set: TB_FILE, TOPLEVEL, TEST_MODULE

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(PWD)/../../src

# All RTL sources + the testbench wrapper
VERILOG_SOURCES = $(wildcard $(SRC_DIR)/*.sv) $(PWD)/$(TB_FILE)

# SystemVerilog support and include path
COMPILE_ARGS += -g2012
COMPILE_ARGS += -I$(SRC_DIR)

# cocotb settings
COCOTB_TEST_MODULES = $(TEST_MODULE)

include $(shell cocotb-config --makefiles)/Makefile.sim
