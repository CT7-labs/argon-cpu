#include "tests.h"
#include "regfile_functions.h"

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

void latchF(int value) {
    top->read_id = ID_REGFILE;
    top->write_id = ID_DEBUG;

    top->o_debug = value;
    top->o_debug_valid = 1;
    top->read_command = REGFILE::COM_LATCHF;

    printf("Debug - command: 0x%x, value: 0x%x, valid: %d\n", 
           top->read_command, top->o_debug, top->o_debug_valid);
    
    simClock();
}

void testFRegister() {
    latchF(0x55);  // Try to write
    // Add small delay
    for(int i = 0; i < 5; i++) simClock();
    
    // Try to read back
    top->read_id = ID_REGFILE;
    top->write_id = ID_DEBUG;
    top->read_command = REGFILE::COM_READF;
    simClock();
    printf("F Register value after write: 0x%x\n", top->i_debug);
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

int regfiletest() {
    simReset();

    testFRegister();

    latchF(0x00FF);

    indexSelect(REGFILE::R0, REGFILE::R4, REGFILE::F);
    latchC(0xAAAA);

    latchF(0x00FF);
    indexSelect(REGFILE::F, REGFILE::R0, REGFILE::R0);

    int value = readA();

    std::cout << "HEX: " << std::hex << std::uppercase 
              << std::setw(4) << std::setfill('0') 
              << (value & ((1ULL << WORDSIZE) - 1))
              << "\n";

    simReset();

    return 0;
}