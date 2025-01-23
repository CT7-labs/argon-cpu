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

void simClock(int i = 1) {
    for (int j = 0; j < i; j++) {
        simClockRise();
        simClockFall();
    }
}

void simReset(int i = 1) {
    top->i_Reset = 1;

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
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("simtop.vcd");
    
    
    // Reset
    simReset();
    simClockFall();

    // "add" program begin
    top->read_id = 1; // ALU is reading from the bus
    top->write_id = 3; // debug is writing to the bus
    top->o_debug_valid = 1; // debug output is valid

    top->read_command = 1; // ALU latchA
    top->o_debug = 15; // debug is outputing 15 on the bus
    simClock();



    top->read_command = 2; // ALU latchB
    top->o_debug = 22; // debug is outputing 22 on the bus
    simClock();



    top->read_command = 4; // ALU latchOp
    top->o_debug = 0; // debug is outputing 0 (ADD opcode) on the bus
    simClock();


    top->o_debug_valid = 0; // debug output is no longer valid
    top->read_command = 0;
    top->o_debug = 0;
    
    top->read_id = 3; // debug is reading from the bus
    top->write_id = 1; // ALU is writing to the bus

    top->write_command = 5; // ALU outputY
    simClock(2);

    uint16_t result = top->i_debug;

    simReset();


    cout << result << "\n";

    // Cleanup
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}