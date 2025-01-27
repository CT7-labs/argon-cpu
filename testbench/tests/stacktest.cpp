#include "tests.h"

void push(int x) {
    top->write_id = ID_DEBUG;
    top->read_id = ID_STACK;
    top->o_debug = x;
    top->o_debug_valid = 1;
    top->read_command = STACK::COM_PUSH;

    simClock();
}

int pop() {
    top->write_id = ID_STACK;
    top->read_id = ID_DEBUG;
    top->o_debug = 0;
    top->o_debug_valid = 0;
    top->write_command = STACK::COM_POP;

    simClock();

    int x = top->i_debug;
    return x;
}

void loadPointer(int x) {
    top->write_id = ID_DEBUG;
    top->read_id = ID_STACK;
    top->o_debug = x;
    top->o_debug_valid = 1;
    top->read_command = STACK::COM_LOAD_PTR;

    simClock();
}

int readPointer() {
    top->write_id = ID_STACK;
    top->read_id = ID_DEBUG;
    top->o_debug = 0;
    top->o_debug_valid = 0;
    top->write_command = STACK::COM_READ_PTR;

    simClock();

    int ptr = top->i_debug;
    return ptr;
}

int stacktest() {
    simReset();
    simClock();

    std::cout << "Pushed 0x00FF\n";
    push(0x00FF);
    std::cout << "Pushed 0xFF00\n";
    push(0xFF00);
    std::cout << "Pushed 0xAA00\n";
    push(0xAA00);
    std::cout << "Pushed 0x00AA\n";
    push(0x00AA);

    std::cout << "Current pointer: " << readPointer() << "\n";

    std::cout << "Popped: " << pop() << "\n";
    std::cout << "Popped: " << pop() << "\n";
    std::cout << "Popped: " << pop() << "\n";
    std::cout << "Popped: " << pop() << "\n";

    push (0xFF00);

    std::cout << "Current pointer: " << readPointer() << "\n";

    simReset();

    return 0;
}