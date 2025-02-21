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

    while (top->o_mem_status != MEM::ST_READY) {
        simClock();
    }
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
    while (top->o_mem_status != MEM::ST_READY) {
        simClock();
    }

    return top->i_debug; // return temp
}

int memcontroller_test() {
    simReset();

    memWriteDebug(0, 16);
    int test0 = memReadDebug(0);
    memWriteDebug(1, 32);
    int test1 = memReadDebug(1);
    memWriteDebug(2, 8);
    int test2 = memReadDebug(3);

    std::cout << test0 << " " << test1 << " " << test2 << "\n";
    simReset();

    return 0;
}