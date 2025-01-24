#include "../sim_header.h"

using namespace std;
using namespace REGFILE;

int regfile_test0(VSimTop* top, VerilatedFstC* tfp) {
    bool return_code = 0; // successful simulation

    simReset(); // not super necessary but pretty swell

    top->read_id = UID::REGFILE;
    top->write_id = UID::DEBUG;
    top->read_command = COM_LATCHSEL;
    top->o_debug = getSelectBits(R1, R2, R3);
    top->o_debug_valid = 1;
    simClock();

    top->read_command = COM_LATCHC;
    top->o_debug = 0xAAAA;
    simClock();

    simReset(); // not super necessary but pretty swell

    return return_code;
}