#include <iostream>
#include <verilated.h>
#include <string.h>
#include "VSimTop.h"

using namespace std;

// Global pointer to the top module
VSimTop* top = nullptr;

// Helper function to print results
void printTest(const char* testName, bool passed) {
    cout << testName << ": " << (passed ? "PASSED" : "FAILED") << std::endl;
}

void simReset() {
    top->i_Reset = 1;
    top->i_Clk = 0;
    top->eval();
    top->i_Reset = 0;
}

void simClock(int i = 1) {
    for (int j = 0; j < i; j++) {
        top->i_Clk = 1;
        top->eval();
        top->i_Clk = 0;
        top->eval();
        cout << "yeet\n";
    }
}

int main(int argc, char** argv) {
    bool fromMakefile = false;
    
    // Check arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--fromMake") == 0) {
            fromMakefile = true;
        }
    }

    // Different behavior based on how it was launched
    if (fromMakefile) {
        cout << "\n\nRunning Verilator simulation from Makefile\n\n";
    } else {
        cout << "\n\nRunning Verilator simulation standalone\n\n";
    }

    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    // Create instance of module
    top = new VSimTop;
    
    // Reset
    simReset();
    
    // addition test! 15 + 22
    // latch 15 into ALU
    top->i_latchA = 1;
    top->i_bus = 15;
    simClock();
    top->i_latchA = 0;

    // latch 22 into ALU
    top->i_latchB = 1;
    top->i_bus = 22;
    simClock();
    top->i_latchB = 0;

    // latch opcode into ALU
    top->i_latchOp = 1;
    top->i_bus = 0;
    simClock();
    top->i_latchOp = 0;
    top->i_bus = 0; // not necessary, but good practice

    // output result
    top->i_outputY = 1;
    simClock(2);
    top->i_outputY = 0;

    // store result
    bool bus_valid = top->o_bus_valid;
    uint16_t result = top->o_bus;

    // display result
    cout << "Attempted to add 15 + 22 = 37\n";
    cout << "Argon ALU got the result\n15 + 22 = " << result << "\n";
    cout << "Argon ALU's o_bus valid? " << bus_valid << "\n";

    // Cleanup
    delete top;
    return 0;
}