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

    indexSelect(REGFILE::R0, REGFILE::R4, REGFILE::R4);
    latchC(255 << 4);

    std::cout << readA() << "\n";
    std::cout << readB() << "\n";

    indexSelect(REGFILE::R4, REGFILE::SP, REGFILE::R0);
    latchC(255 << 2);

    std::cout << readA() << "\n";
    std::cout << readB() << "\n";

    indexSelect(REGFILE::R0, REGFILE::R4, REGFILE::R4);
    latchC(255 << 4);

    std::cout << readA() << "\n";
    std::cout << readB() << "\n";

    simReset();

    return 0;
}