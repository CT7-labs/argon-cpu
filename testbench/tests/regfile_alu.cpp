#include "tests.h"

void indexSelect(int a, int b, int c) {
    top->read_id = ID_REGFILE;
    top->write_id = ID_DEBUG;

    top->o_debug = a | b << REGFILE::INDEX_WIDTH | c << REGFILE::INDEX_WIDTH * 2;
    top->o_debug_valid = 1;
    top->read_command = REGFILE::COM_LATCHSEL;
    simClock();
}

void latchC(int value) {
    top->read_id = ID_REGFILE;
    top->write_id = ID_DEBUG;

    top->o_debug = value;
    top->o_debug_valid = 1;
    top->read_command = REGFILE::COM_LATCHC;
    simClock();
}

int readA() {
    top->read_id = ID_DEBUG;
    top->write_id = ID_REGFILE;

    top->o_debug = 0;
    top->o_debug_valid = 0;
    top->write_command = REGFILE::COM_READA;
    simClock();

    return top->i_debug;
}

int readB() {
    top->read_id = ID_DEBUG;
    top->write_id = ID_REGFILE;

    top->o_debug = 0;
    top->o_debug_valid = 0;
    top->write_command = REGFILE::COM_READB;
    simClock();

    return top->i_debug;
}

void compute(int op, int regA, int regB, int regC) {
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
    return 0;
}