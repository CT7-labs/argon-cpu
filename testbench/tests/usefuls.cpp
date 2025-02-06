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

void push(int reg) {
    selectRegisters(reg, 0, 0);

    // push
    top->read_id = ID_STACK;
    top->write_id = ID_REGFILE;
    top->o_debug_valid = 0;

    top->read_command = STACK::COM_PUSH;
    top->write_command = REGFILE::COM_READA;
    simClock();

    // decrement SP
    top->write_command = REGFILE::COM_SP_DEC;
    top->read_command = 0;
    simClock();
}

void pop(int reg) {
    selectRegisters(0, 0, reg);

    // pop
    top->read_id = ID_REGFILE;
    top->write_id = ID_STACK;
    top->o_debug_valid = 0;

    top->read_command = REGFILE::COM_LATCHC;
    top->write_command = STACK::COM_POP;
    simClock();

    // increment SP
    top->read_command = REGFILE::COM_SP_INC;
    top->write_command = 0;
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
    top->o_debug_valid = 0;

    top->read_command = REGFILE::COM_ALU_WE;
    top->write_command = ALU::COM_WRITEC;
    simClock();

    // latch flags to F
    // doesn't matter which is read or write, just so long as we can
    // pass a command to both modules
    top->read_id = ID_REGFILE;
    top->write_id = ID_ALU;
    top->o_debug_valid = 0;

    top->read_command = REGFILE::COM_ALU_WE;
    top->write_command = ALU::COM_WRITEF;
    simClock();
    top->read_command = 0;
    top->write_command = 0;
}
