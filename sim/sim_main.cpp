#include <iostream>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include <string.h>
#include "VSimTop.h"

using namespace std;

// Global pointer to the top module
VSimTop* top = nullptr;
VerilatedVcdC* tfp = nullptr;
vluint64_t main_time = 0;

// Helper function to print results
void printTest(const char* testName, bool passed) {
    cout << testName << ": " << (passed ? "PASSED" : "FAILED") << std::endl;
}

void simReset() {
    top->i_Reset = 1;
    top->i_Clk = 0;

    top->eval();
    top->i_Reset = 0;
    top->i_Clk = 1;

    if (tfp) tfp->dump(main_time);
    main_time++;

    top->eval();

    if (tfp) tfp->dump(main_time);
    main_time++;
}

void simClock(int i = 1) {
    for (int j = 0; j < i; j++) {
        top->i_Clk = 0;
        top->eval();
        if (tfp) tfp->dump(main_time);
        main_time++;

        top->i_Clk = 1;
        top->eval();
        if (tfp) tfp->dump(main_time);
        main_time++;
    }
}

int main(int argc, char** argv) {
    bool fromMakefile = false;
    
    // Check arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--fromMake") == 0) {
            fromMakefile = true;
        }
        else if (strcmp(argv[i], "--traceOn") == 0) {
            traceOn = true;
        }
    }

    // Different behavior based on how it was launched
    if (fromMakefile) {
        cout << "\n\nRunning Verilator simulation from Makefile\n";
    } else {
        cout << "\n\nRunning Verilator simulation standalone\n";
    }
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    // Create instance of module
    top = new VSimTop;

    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("simtop.vcd");
    // Reset
    simReset();

    top->read_id = 3; // debug
    top->write_id = 1; // ALU

    // addition test! 15 + 22
    // latch 15 into ALU
    top->i_latchA = 1;
    top->o_debug = 15; // output from debug device onto bus
    top->o_debug_valid = 1; // make sure the internal logic knows we're outputting valid data
    simClock();
    top->i_latchA = 0;
    top->o_debug_valid = 0; // testing

    cout << top->i_debug << "\n";

    // latch 22 into ALU
    top->i_latchB = 1;
    top->o_debug = 22;
    top->o_debug_valid = 1;
    simClock();
    top->i_latchB = 0;
    top->o_debug_valid = 0;

    // latch opcode into ALU
    top->i_latchOp = 1;
    top->o_debug = 0;
    top->o_debug_valid = 1;
    simClock();
    top->i_latchOp = 0;
    top->o_debug_valid = 0;
    top->o_debug = 0; // not necessary for this sim, but good practice

    // output result
    top->read_id = 1; // debug is reading now
    top->write_id = 3; // ALU is writing now
    top->i_outputY = 1;
    simClock(2);
    top->i_outputY = 0; // not necessary for this sim, but good practice

    // store result
    bool bus_valid = top->i_debug_valid; // read from bus
    uint16_t result = top->i_debug;

    // reset for testing purposes
    simReset();

    // display result
    cout << "Attempted to add 15 + 22 = 37\n";
    cout << "Argon ALU got the result\n15 + 22 = " << result << "\n";
    cout << "Argon ALU's i_debug valid? " << bus_valid << "\n";

    // Cleanup
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}