#include "../test_functions.h"

using namespace std;

void add37(VSimTop* top, VerilatedFstC* tfp) {
    // Reset
    simReset();

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
    simClock();

    uint16_t result = top->i_debug;

    simReset();

    cout << result << "\n";
}