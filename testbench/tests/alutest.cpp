#include "tests.h"
#include "../testbench.h"

int alutest(VSimTop* top, VerilatedFstC* tfp) {
    simReset();

    top->o_debug = 32;
    top->o_debug_valid = 1;
    top->write_id = 3;
    top->read_id = 1;
    top->read_command = 1;
    simClock();

    simReset();

    return 0;
}