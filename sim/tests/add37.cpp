#include "../sim_header.h"

using namespace std;

void add37(VSimTop* top, VerilatedFstC* tfp) {
    cout << "=== Running \"add37\" simulation ===\ntesting ALU functionality\n\n";

    // Reset
    simReset();

    // "add" program begin
    top->read_id = 1; // ALU is reading from the bus
    top->write_id = 3; // debug is writing to the bus
    top->o_debug_valid = 1; // debug output is valid

    top->read_command = 1; // ALU latchA
    top->o_debug = 15; // debug is outputing 15 on the bus
    simClock();



    top->read_command = ALU::COM_LATCHB; // ALU latchB
    top->o_debug = 21; // debug is outputing 22 on the bus
    simClock();

    top->read_command = ALU::COM_LATCHF; // ALU latchF
    top->o_debug = ALU::F_CARRY; // debug is outputing 22 on the bus
    simClock();

    top->read_command = ALU::COM_LATCHOP; // ALU latchOp
    top->o_debug = 1; // debug is outputing 0 (ADD opcode) on the bus
    simClock();

    top->read_command = ALU::COM_COMPUTE; // ALU compute
    top->o_debug = 0; // output isn't really necessary so setting it to zero
    top->o_debug_valid = 0; // debug output is no longer valid
    simClock();


    top->read_command = 0; // setting debug read_command to 0
    top->o_debug = 0; // not outputting anything from debug
    top->read_id = 3; // debug is reading from the bus
    top->write_id = 1; // ALU is writing to the bus

    top->write_command = ALU::COM_OUTPUTY; // ALU outputY
    simClock();

    uint16_t result = top->i_debug;

    simReset();

    cout << result << "\n";
}