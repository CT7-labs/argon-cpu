#ifndef CONSTANTS_H
#define CONSTANTS_H

namespace Constants {
    // probably not needed but they're here
    const int WORDSIZE      = 16;
    const int REGISTERS     = 16;    
}

namespace UID {
    // ID constants
    const int ALU        = 0x1;
    const int REGFILE    = 0x2;
    const int DEBUG      = 0x3;
    const int STACK      = 0x4;
}

namespace ALU {
    const int OP_ADD   = 0x0;
    const int OP_ADC   = 0x1;
    const int OP_SBC   = 0x2;
    const int OP_CMP   = 0x3;
    const int OP_INC   = 0x4;
    const int OP_DEC   = 0x5;
    const int OP_NAND  = 0x6;
    const int OP_AND   = 0x7;
    const int OP_OR    = 0x8;
    const int OP_NOR   = 0x9;
    const int OP_XOR   = 0xA;
    const int OP_LSH   = 0xB;
    const int OP_RSH   = 0xC;

    const int COM_LATCHA    = 1;
    const int COM_LATCHB    = 2;
    const int COM_LATCHF    = 3;
    const int COM_LATCHOP   = 4;
    const int COM_OUTPUTY   = 5;
    const int COM_OUTPUTF   = 6;
    const int COM_COMPUTE   = 7;

    // flag constants
    const int F_CARRY     = 1 << 0;
    const int F_ZERO      = 1 << 1;
    const int F_EQUAL     = 1 << 2;
    const int F_GREATER   = 1 << 3;
    const int F_LESS      = 1 << 4;
    const int F_BORROW    = 1 << 5;
    const int F_ERROR     = 1 << 15;
}

#endif