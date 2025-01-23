#include <verilated.h>
#include "verilated_fst_c.h"
#include "VSimTop.h"
#include <iostream>
#include <string.h>
#include "test_functions.h"

using namespace std;

// Global pointer to the top module
VSimTop* top = nullptr;

// Globals for .fst waveform dump
VerilatedFstC* tfp = nullptr;
vluint64_t main_time = 0;

// helpful simulation functions

void simClockFall() {
    top->i_Clk = 0;
    top->eval();
    tfp->dump(main_time);
    main_time++;
}

void simClockRise() {
    top->i_Clk = 1;
    top->eval();
    tfp->dump(main_time);
    main_time++;
}

void simClock(int i) {
    for (int j = 0; j < i; j++) {
        simClockRise();
        simClockFall();
    }
}

void simReset(int i) {
    top->i_Reset = 1;

    if (main_time == 0) {
        simClockFall();
    }

    simClock(i);

    top->i_Reset = 0;
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
        cout << "\n\nRunning Verilator simulation from Makefile\n";
    } else {
        cout << "\n\nRunning Verilator simulation standalone\n";
    }
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    // Create instance of module
    top = new VSimTop;

    Verilated::traceEverOn(true);
    tfp = new VerilatedFstC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("simtop.fst");
    
    // run test
    add37(top, tfp);

    cout << "\""<< ALU::OP::LSH << "\"\n";

    // Cleanup
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}