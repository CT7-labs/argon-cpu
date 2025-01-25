#include "tests.h"
#include "../testbench.h"

using namespace std;

struct result_t {
    int result;
    int flags;
};

result_t alu_compute(int a, int b, int op, int f) {
    // make debug the bus driver
    top->write_id = ID_DEBUG;
    top->read_id = ID_ALU;

    top->o_debug_valid = 1;

    // latch A
    top->o_debug = a;
    top->read_command = ALU::COM_LATCHA;
    simClock();

    // latch B
    top->o_debug = b;
    top->read_command = ALU::COM_LATCHB;
    simClock();

    // latch Op
    top->o_debug = op;
    top->read_command = ALU::COM_LATCHOP;
    simClock();

    // latch F
    top->o_debug = f;
    top->read_command = ALU::COM_LATCHF;
    simClock();

    // compute
    top->o_debug_valid = 0; // not necessary but a nice-to-have
    top->read_command = ALU::COM_COMPUTE;
    simClock();

    // make ALU the bus driver
    top->write_id = ID_ALU;
    top->read_id = ID_DEBUG;

    // read Y
    top->write_command = ALU::COM_OUTPUTY;
    simClock();
    int result = top->i_debug;

    // read F
    top->write_command = ALU::COM_OUTPUTF;
    simClock();
    int flags = top->i_debug;
    
    return result_t{result, flags};
}

int alutest() {
    simReset();
    
    result_t result;
    result = alu_compute(15, 22, ALU::OP_ADD, 0);

    cout << result.result;

    simReset();

    return 0;
}