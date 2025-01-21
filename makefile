# Default to no trace
TRACE ?= 0

# Directory structure
HDL_DIR = hdl
SRC_DIR = sim
OBJ_DIR = obj_dir
PKG_DIR = hdl/pkg

# Find SystemVerilog files
PKG_FILES := $(wildcard $(PKG_DIR)/*.sv)
VERILOG_FILES := $(wildcard $(HDL_DIR)/*.sv)

# Debug prints
$(info PKG_DIR = $(PKG_DIR))
$(info PKG_FILES = $(PKG_FILES))
$(info VERILOG_FILES = $(VERILOG_FILES))

# top module name
TOP_MODULE = SimTop

# C++ source in src directory
CPP_SRC = $(SRC_DIR)/sim_main.cpp

# Executable name
EXECUTABLE = $(OBJ_DIR)/V$(TOP_MODULE)

# Verilator flags
VERILATOR_FLAGS = --cc --exe --build -j -Wno-fatal

# Add trace flags if TRACE=1
ifeq ($(TRACE), 1)
    VERILATOR_FLAGS += --trace
    VERILATOR_FLAGS += -CFLAGS "-DTRACE"
endif

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
	$(EXECUTABLE) --fromMake

# Pattern match for 'trace' in targets
%trace:
	$(MAKE) TRACE=1 $(subst trace,,$@)

# Clean output files
clean:
	rm -rf $(OBJ_DIR)

.PHONY: all clean run