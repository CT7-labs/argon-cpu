#include "testbench.h"

using namespace std;
using namespace std::chrono;

// init globals
VSimTop* top = nullptr;
VerilatedFstC* tfp = nullptr;
vluint64_t main_time = 0;
uint64_t clock_count = 0;

// helpful testbench functions

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

// critical testbench functions

void initTestbench(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    top = new VSimTop;
    Verilated::traceEverOn(true);
    tfp = new VerilatedFstC;
    top->trace(tfp, 99);
    tfp->open("wavedump.fst");

    // put simulation in a known state
    clock_count = 0;
}

void cleanup() {
    tfp->close();
    delete tfp;
    delete top;
}

void runTest() {
    simClock(1000);
}