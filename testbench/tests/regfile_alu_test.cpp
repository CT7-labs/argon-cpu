#include "tests.h"

void selectRegisters(int a, int b, int c) {
    top->read_id = ID_REGFILE;
    top->write_id = ID_DEBUG;
    top->o_debug_valid = 1;

    top->read_command = REGFILE::COM_LATCHSEL;
    top->o_debug = a | b << REGFILE::INDEX_WIDTH | c << REGFILE::INDEX_WIDTH * 2;

    simClock();
}

int readA() {
    top->write_id = ID_REGFILE;
    top->read_id = ID_DEBUG;

    top->write_command = REGFILE::COM_READA;
    
    simClock();

    return top->i_debug;
}

int readB() {
    top->write_id = ID_REGFILE;
    top->read_id = ID_DEBUG;

    top->write_command = REGFILE::COM_READB;
    
    simClock();

    return top->i_debug;
}

int readF() {
    top->write_id = ID_REGFILE;
    top->read_id = ID_DEBUG;

    top->write_command = REGFILE::COM_READF;
    
    simClock();

    return top->i_debug;
}

void writeC(int value) {
    top->read_id = ID_REGFILE;
    top->write_id = ID_DEBUG;
    top->o_debug_valid = 1;
    top->read_command = REGFILE::COM_LATCHC;
    top->o_debug = value;
    simClock();
}

void compute(int op, int a, int b, int c) {
    selectRegisters(a, b, c);

    // latch op
    top->read_id = ID_ALU;
    top->write_id = ID_DEBUG;
    top->o_debug_valid = 1;

    top->read_command = ALU::COM_LATCHOP;
    top->o_debug = op;
    simClock();

    // latch result to C
    // doesn't matter which is read or write, just so long as we can
    // pass a command to both modules
    top->read_id = ID_REGFILE;
    top->write_id = ID_ALU;

    top->read_command = REGFILE::COM_ALU_WE;
    top->write_command = ALU::COM_WRITEC;
    simClock();

    // latch flags to F
    // doesn't matter which is read or write, just so long as we can
    // pass a command to both modules
    top->read_id = ID_REGFILE;
    top->write_id = ID_ALU;

    top->read_command = REGFILE::COM_ALU_WE;
    top->write_command = ALU::COM_WRITEF;
    simClock();
}

int regfile_alu_test() {
    simReset();

    // LDA 12
    selectRegisters(R_GP1, R_GP2, R_GP1);
    writeC(12);

    // LDB 25
    selectRegisters(R_GP1, R_GP2, R_GP2);
    writeC(25);
    
    // compute A + B
    compute(ALU::OP_ADD, R_GP1, R_GP2, R_GP1);

    std::cout << readA() << "\n";
    std::cout << readF() << "\n";

    simReset();
    return 0;
}