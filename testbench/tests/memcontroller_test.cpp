#include "tests.h"

void memWriteDebug(int addr, int imm16) {
    top->read_id = ID_MEM;
    top->write_id = ID_DEBUG;
    top->o_debug_valid = 1;

    // load memory pointer
    top->read_command = MEM::COM_LATCH_MP;
    top->o_debug = addr;
    simClock();

    // load data
    top->read_command = MEM::COM_WRITE;
    top->o_debug = imm16;
    simClock();
}

int memReadDebug(int addr) {
    top->read_id = ID_MEM;
    top->write_id = ID_DEBUG;
    top->o_debug_valid = 1;

    // load memory pointer
    top->o_debug = addr;
    top->read_command = MEM::COM_LATCH_MP;
    simClock();

    // latch temp
    top->read_id = ID_DEBUG;
    top->write_id = ID_MEM;
    top->o_debug_valid = 0;

    top->write_command = MEM::COM_READ;
    simClock();

    // read temp
    top->write_command = MEM::COM_TEMP_OUT;
    simClock();

    return top->i_debug; // return temp
}

int memcontroller_test() {
    simReset();

    memWriteDebug(0, 16);
    int test = memReadDebug(0);

    simReset();

    return test;
}