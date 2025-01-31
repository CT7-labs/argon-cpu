#include "tests.h"
#include "regfile_functions.h"

void regfile_compute(int op, int regA, int regB, int regC) {
    indexSelect(regA, regB, regC);

    // latch opcode
    top->read_id = ID_ALU;
    top->write_id = ID_DEBUG;
    top->o_debug_valid = 1;

    top->read_command = ALU::COM_LATCHOP;
    simClock();

    top->o_debug_valid = 0;

    // latch A, B, and F
    top->read_id = ID_ALU;
    top->write_id = ID_REGFILE;

    top->read_command = ALU::COM_LATCHA;
    top->write_command = REGFILE::COM_READA;
    simClock();

    top->read_command = ALU::COM_LATCHB;
    top->write_command = REGFILE::COM_READB;
    simClock();

    top->read_command = ALU::COM_LATCHF;
    top->write_command = REGFILE::COM_READF;
    simClock();

    // compute
    top->read_command = ALU::COM_COMPUTE;
    top->write_command = 0; // don't do anything
    simClock();

    // write result and flags to register file
    top->read_id = ID_REGFILE;
    top->write_id = ID_ALU;

    top->read_command = REGFILE::COM_LATCHC;
    top->write_command = ALU::COM_OUTPUTY;
    simClock();

    top->read_command = REGFILE::COM_LATCHF;
    top->write_command = ALU::COM_OUTPUTF;
    simClock();
}

int regfile_alu() {
    indexSelect(REGFILE::R1, REGFILE::R2, REGFILE::R1);
    latchC(255);
    indexSelect(REGFILE::R1, REGFILE::R2, REGFILE::R2);
    latchC(255);

    regfile_compute(ALU::OP_ADD, REGFILE::R1, REGFILE::R2, REGFILE::R3);

    return 0;
}