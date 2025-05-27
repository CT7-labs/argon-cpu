# Makefile for Verilating and running simulations to assist Argon's development
RTL_DIR = rtl
TOP_MODULE = Argon
SIM_DIR = sim
OBJ_NAME = VArgon
SIM_OBJ = $(SIM_DIR)/$(OBJ_NAME)
TRACE_FILE = dump.fst

VERILATOR = verilator
VERILATOR_FLAGS = -Wno-fatal --cc --exe --build -o $(OBJ_NAME) --trace-fst

# this is a test

# Source files
VERILOG_FILES = $(wildcard $(RTL_DIR)/*.sv)
CPP_FILES = testbench.cpp

# Default target: Verilate but don't run
.PHONY: all clean run
default: $(SIM_OBJ)

# Verilate the design with FST tracing
$(SIM_OBJ): $(VERILOG_FILES) $(CPP_FILES)
	$(VERILATOR) $(VERILATOR_FLAGS) -I$(RTL_DIR) --top-module $(TOP_MODULE) $(VERILOG_FILES) $(CPP_FILES) --Mdir $(SIM_DIR)

# Run the simulation and generate waveform
run: $(SIM_OBJ)
	$(SIM_DIR)/$(OBJ_NAME)
	@echo "Waveform dumped to $(TRACE_FILE)"

# Clean up generated files, including trace file
clean:
	rm -rf $(SIM_DIR) *.fst

# All: Clean, verilate, and run
all: clean $(SIM_OBJ) run