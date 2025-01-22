# Directory structure
HDL_DIR = hdl
SRC_DIR = sim
OBJ_DIR = obj_dir
PKG_DIR = hdl/pkg

# Find SystemVerilog files
PKG_FILES := $(wildcard $(PKG_DIR)/*.sv)
VERILOG_FILES := $(wildcard $(HDL_DIR)/*.sv)

# Debug prints
$(info PKG_FILES = $(PKG_FILES))
$(info VERILOG_FILES = $(VERILOG_FILES))

# top module name
TOP_MODULE = SimTop

# C++ source in src directory
CPP_SRC = $(SRC_DIR)/sim_main.cpp

# Executable name
EXECUTABLE = $(OBJ_DIR)/V$(TOP_MODULE)
EXECUTABLE_FLAGS = --fromMake

# Verilator flags
VERILATOR_FLAGS = --cc --exe --build -j -Wno-fatal --trace

# Make sure the obj directory exists
$(shell mkdir -p $(OBJ_DIR))
$(shell mkdir -p $(HDL_DIR))
$(shell mkdir -p $(SRC_DIR))

# Default target
all: $(EXECUTABLE)

# Verilate and build
$(EXECUTABLE): $(PKG_FILES) $(VERILOG_FILES) $(CPP_SRC)
	@echo "Building $(EXECUTABLE)..."
	verilator $(VERILATOR_FLAGS) \
		-CFLAGS "-std=c++11" \
		--top-module $(TOP_MODULE) \
		--Mdir $(OBJ_DIR) \
		$(PKG_FILES) \
		$(VERILOG_FILES) \
		$(CPP_SRC)
	@if [ ! -f $(EXECUTABLE) ]; then \
		echo "Error: Build failed - executable not created"; \
		exit 1; \
	fi

# Run the simulation
run: $(EXECUTABLE)
	@if [ ! -x $(EXECUTABLE) ]; then \
		echo "Error: $(EXECUTABLE) not found or not executable"; \
		exit 1; \
	fi
	$(EXECUTABLE) $(EXECUTABLE_FLAGS)

# Clean output files
clean:
	rm -rf $(OBJ_DIR)
	rm -f *.vcd

.PHONY: all clean run