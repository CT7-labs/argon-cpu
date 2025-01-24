#include <verilated.h>
#include "verilated_fst_c.h"
#include "VSimTop.h"
#include <iostream>
#include <string.h>
#include <chrono>
#include "sim_header.h"

using namespace std;
using namespace std::chrono;

// Global pointer to the top module
VSimTop* top = nullptr;

// Globals for .fst waveform dump
VerilatedFstC* tfp = nullptr;
vluint64_t main_time = 0;
uint64_t clock_count = 0;

// helpful simulation functions

void simClockFall() {
    /*
    Simulation clock falls
    */
    top->i_Clk = 0;
    top->eval();
    tfp->dump(main_time);
    main_time++;
}

void simClockRise() {
    /*
    Rises simulation clock
    */
    top->i_Clk = 1;
    top->eval();
    tfp->dump(main_time);
    main_time++;
}

void simClock(int i) {
    /*
    Steps simulation through i clock cycles
    */
    for (int j = 0; j < i; j++) {
        simClockFall();
        simClockRise();
        clock_count++;
    }
}

void simReset() {
    /*
    Holds i_Reset high on a rising and falling edge
    */
    top->i_Reset = 1;

    simClock();

    simClockFall();

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
        cout << "\n\nRunning Verilator simulation from Makefile\n\n";
    } else {
        cout << "\n\nRunning Verilator simulation standalone\n\n";
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
    clock_count = 0;
    auto start_time = high_resolution_clock::now();

    int return_code = regfile_test0(top, tfp);

    // end test
    auto end_time = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(end_time - start_time);

    cout    << "\n=== Simulation completed ==="
            << "\n Return code: " << return_code
            << "\n  Clock cycles: " << clock_count
            << "\n  Real time: " << duration.count() << " us"
            << "\n  Average speed: " << (clock_count * 100000.0 / duration.count()) << " Hz\n\n";

    // Cleanup
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}