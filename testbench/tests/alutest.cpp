#include "tests.h"
#include <random>

using namespace std;

struct result_t {
    int a, b, op, f;
    int value;
    int flags;
};

// helpfuls
int randomInt(int min, int max) {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(min, max);
    return dis(gen);
}

result_t alu_compute(int a, int b, int op, int f) {
    // make debug the bus driver
    top->write_id = ID_DEBUG;
    top->read_id = ID_ALU;

    top->o_debug_valid = 1;

    // latch A
    top->o_debug = a;
    top->read_command = ALU::COM_LATCHA;
    simClock();

    // latch B
    top->o_debug = b;
    top->read_command = ALU::COM_LATCHB;
    simClock();

    // latch Op
    top->o_debug = op;
    top->read_command = ALU::COM_LATCHOP;
    simClock();

    // latch F
    top->o_debug = f;
    top->read_command = ALU::COM_LATCHF;
    simClock();

    // compute
    top->o_debug_valid = 0; // not necessary but a nice-to-have
    top->read_command = ALU::COM_COMPUTE;
    simClock();

    // make ALU the bus driver
    top->write_id = ID_ALU;
    top->read_id = ID_DEBUG;

    // read Y
    top->write_command = ALU::COM_OUTPUTY;
    simClock();
    int result = top->i_debug;

    // read F
    top->write_command = ALU::COM_OUTPUTF;
    simClock();
    int flags = top->i_debug;
    
    return result_t{a, b, op, f, result, flags};
}

// pretty printing
void printFlags(int flags) {
    // Print flags in binary
    std::cout << "  E-BLGEZC\n  ";
    for (int i = 7; i >= 0; i--) {
        std::cout << ((flags >> i) & 1);
    }
    std::cout << "\n";
}

void printResult(result_t result) {
    std::cout << "Operands:\n";
    std::cout << "  A: " << result.a << "\n";
    std::cout << "  B: " << result.b << "\n";
    std::cout << "  Op: " << ALU::opnames[result.op] << "\n";
    std::cout << "Flags:\n";
    printFlags(result.f);

    std::cout << "Result:\n";
    
    // Hexadecimal (number of hex digits = wordsize/4 rounded up)
    int hexDigits = (WORDSIZE + 3) / 4;
    std::cout << "  HEX: " << std::hex << std::uppercase 
              << std::setw(hexDigits) << std::setfill('0') 
              << (result.value & ((1ULL << WORDSIZE) - 1)) 
              << std::dec << "\n";
    
    // Decimal
    std::cout << "  DEC: " << (result.value & ((1ULL << WORDSIZE) - 1)) << "\n";
    
    // Binary with spacing every 4 bits
    std::cout << "  BIN: ";
    for (int i = WORDSIZE - 1; i >= 0; i--) {
        if (i < WORDSIZE - 1 && i % 4 == 3) std::cout << ' ';
        std::cout << ((result.value >> i) & 1);
    }
    std::cout << "\n";

    std::cout << "Flags:\n";
    printFlags(result.flags);
    std::cout << "\n";
}

// actual test
int alutest() {
    simReset();
    
    int a = 10;
    int b = 8;
    int carry = 0;

    result_t result;
    result = alu_compute(a, b, ALU::OP_SBB, 0);

    printResult(result);

    result = alu_compute(b, a, ALU::OP_SBB, result.flags);

    printResult(result);

    result = alu_compute(a, b, ALU::OP_SBB, result.flags);

    printResult(result);

    simReset();

    return 0;
}