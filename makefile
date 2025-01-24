# Directory structure
HDL_DIR = hdl
SRC_DIR = sim
OBJ_DIR = obj_dir
PKG_DIR = $(HDL_DIR)/pkg
COMMON_DIR = $(HDL_DIR)/common
TESTS_DIR = $(SRC_DIR)/tests

# Find SystemVerilog files
PKG_FILES := $(wildcard $(PKG_DIR)/*.sv)
COMMON_FILES := $(wildcard $(COMMON_DIR)/*.sv)
VERILOG_FILES := $(wildcard $(HDL_DIR)/*.sv)

# top module name
TOP_MODULE = SimTop

# C++ source in src directory
SRC_FILES = $(wildcard $(SRC_DIR)/*.cpp)
TEST_FILES = $(wildcard $(TESTS_DIR)/*.cpp)
CPP_SRC = $(SRC_FILES) $(TEST_FILES)

# Executable name
EXECUTABLE = $(OBJ_DIR)/V$(TOP_MODULE)
EXECUTABLE_FLAGS = --fromMake

# Verilator flags
VERILATOR_FLAGS = --cc --exe --build -j -Wno-fatal --trace-fst -I$(HDL_DIR)

# Make sure the obj directory exists
$(shell mkdir -p $(OBJ_DIR))
$(shell mkdir -p $(HDL_DIR))
$(shell mkdir -p $(SRC_DIR))
$(shell mkdir -p $(TESTS_DIR))

# Default target
all: clean build run

# Build target
build: $(EXECUTABLE)

# Verilate and build
$(EXECUTABLE):
	@echo "Building $(EXECUTABLE)..."
	verilator $(VERILATOR_FLAGS) \
		-CFLAGS "-std=c++11" \
		--top-module $(TOP_MODULE) \
		--Mdir $(OBJ_DIR) \
		$(PKG_FILES) \
		$(COMMON_FILES) \
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
	rm -f *.fst

.PHONY: all clean run build