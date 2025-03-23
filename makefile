# Makefile for Verilating and running simulations to assist Argon's development
RTL_DIR = rtl
TOP_MODULE = SimTop
SIM_DIR = obj_dir
OBJ_NAME = VSimTop
SIM_OBJ = $(SIM_DIR)/$(OBJ_NAME)

VERILATOR = verilator
VERILATOR_FLAGS = -Wno-fatal --cc --exe --build -o $(OBJ_NAME)

# Source files
VERILOG_FILES = $(wildcard $(RTL_DIR)/*.sv)
CPP_FILES = testbench.cpp

# Default target: Verilate but don't run
.PHONY: all clean run
default: $(SIM_OBJ)

# Verilate the design
$(SIM_OBJ): $(VERILOG_FILES) $(CPP_FILES)
	$(VERILATOR) $(VERILATOR_FLAGS) -I$(RTL_DIR) --top-module $(TOP_MODULE) $(VERILOG_FILES) $(CPP_FILES) --Mdir $(SIM_DIR)

# Run the simulation
run: $(SIM_OBJ)
	./$(SIM_OBJ)

# Clean up generated files
clean:
	rm -rf $(SIM_DIR)

# All: Clean, verilate, and run
all: clean $(SIM_OBJ) run