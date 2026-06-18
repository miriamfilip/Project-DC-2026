# ==============================================================================
# ModelSim Cache Simulation Makefile
# ==============================================================================

# ModelSim command line tools
VLOG = vlog
VSIM = vsim

# File Paths
SRC_FILES = src/cache_controller.sv src/memory.sv
TB_FILES  = tb/cache_controller_tb.sv
TOP_BLOCK = cache_controller_tb

.PHONY: all compile run clean

# Default target
all: run

# Create work library and compile files
compile:
	vlib work
	$(VLOG) +incdir+src $(SRC_FILES) $(TB_FILES)

# Run simulation in command line mode (or GUI mode if changed)
run: compile
	$(VSIM) -c -do "run -all; quit" $(TOP_BLOCK)

# Open ModelSim GUI with the simulation ready
gui: compile
	$(VSIM) -do "add wave -r /*; run -all" $(TOP_BLOCK) &

clean:
	rm -rf work vsim.wlf transcript