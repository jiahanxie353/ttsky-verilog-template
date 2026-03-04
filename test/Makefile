# Top-level test orchestrator
# Usage:
#   make all          — run every test (unit + integration)
#   make unit         — run all unit tests
#   make integration  — run the full-CPU integration test
#   make test-alu     — run a single unit test (substitute any module name)
#   make clean        — remove all build artifacts

UNIT_DIRS = unit_alu unit_alucontrol unit_control unit_adder \
            unit_nextpc unit_immgen unit_forwarding unit_hazard unit_regfile

.PHONY: all unit integration clean $(UNIT_DIRS)

all: unit integration

unit: $(UNIT_DIRS)

$(UNIT_DIRS):
	@echo "=== Running $@ ==="
	$(MAKE) -C $@

integration:
	@echo "=== Running integration ==="
	$(MAKE) -C integration

# Convenience targets: make test-alu, make test-control, etc.
test-%:
	$(MAKE) -C unit_$*

clean:
	@for d in $(UNIT_DIRS) integration; do \
		$(MAKE) -C $$d clean 2>/dev/null || true; \
	done
