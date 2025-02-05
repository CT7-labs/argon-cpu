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
}

void push(int reg_a) {
    selectRegisters(reg_a, 0, 0);

    // pass reg_a to stack
    top->read_id = ID_STACK;
    top->write_id = ID_REGFILE;
    top->o_debug_valid = 0;

    top->write_command = REGFILE::COM_READA;
    top->read_command = STACK::COM_PUSH;

    simClock();

    top->write_command = 0;
    top->read_command = 0;
}

void pop(int reg_c) {
    selectRegisters(0, 0, reg_c);

    top->read_id = ID_REGFILE;
    top->write_id = ID_STACK;

    top->write_command = STACK::COM_POP;
    top->read_command = REGFILE::COM_LATCHC;

    simClock(2);

    top->write_command = 0;
    top->read_command = 0;
}

int regfile_alu_test() {
    simReset();

    // LDF 1 (carry flag)
    selectRegisters(0, 0, R_F);
    writeC(ALU::F_CARRY);

    // LDA 12
    selectRegisters(0, 0, R_GP1);
    writeC(12);

    // LDB 25
    selectRegisters(0, 0, R_GP2);
    writeC(25);
    
    // compute A + B
    compute(ALU::OP_ADC, R_GP1, R_GP2, R_GP1);

    std::cout << readA() << "\n";
    std::cout << readF() << "\n";

    // push GP1 into stack
    push(R_GP1);

    // pop stack into GP3
    pop(R_GP3);
    selectRegisters(R_GP3, 0, 0);

    std::cout << readA() << "\n";

    simReset();
    return 0;
}