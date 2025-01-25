#ifndef CONSTANTS_H
#define CONSTANTS_H

const int WORDSIZE = 16;
const int COMMAND_WIDTH = 4;

// bus unit IDs
const int ID_ALU =        0x1;
const int ID_REGFILE =    0x2;
const int ID_DEBUG =      0x3;
const int ID_STACK =      0x4;

namespace ALU {

    // commands
    const int COM_LATCHA    = 0x1;
    const int COM_LATCHB    = 0x2;
    const int COM_LATCHF    = 0x3;
    const int COM_LATCHOP   = 0x4;
    const int COM_OUTPUTY   = 0x5;
    const int COM_OUTPUTF   = 0x6;
    const int COM_COMPUTE   = 0x7;

    // opcodes
    const int ALU_ADD   = 0x0;
    const int ALU_ADC   = 0x1;
    const int ALU_SBC   = 0x2;
    const int ALU_CMP   = 0x3;
    const int ALU_INC   = 0x4;
    const int ALU_DEC   = 0x5;
    const int ALU_NAND  = 0x6;
    const int ALU_AND   = 0x7;
    const int ALU_OR    = 0x8;
    const int ALU_NOR   = 0x9;
    const int ALU_XOR   = 0xA;
    const int ALU_LSH   = 0xB;
    const int ALU_RSH   = 0xC;
    const int ALU_ROL   = 0xD;
    const int ALU_ROR   = 0xE;

    // ALU flag constants
    const int F_CARRY   = 1;
    const int F_ZERO    = 1 << 1;
    const int F_EQUAL   = 1 << 2;
    const int F_GREATER = 1 << 3;
    const int F_LESS    = 1 << 4;
    const int F_ERROR   = 1 << 15;
}

namespace REGFILE {

    // commands
    const int COM_READA     = 0x1;
    const int COM_READB     = 0x2;
    const int COM_LATCHC    = 0x3;
    const int COM_LATCHSEL  = 0x4;
    const int COM_READSP    = 0x5;
    const int COM_READF     = 0x6;
    const int COM_SP_INC    = 0x7;
    const int COM_SP_DEC    = 0x8;
    const int COM_LATCHSP   = 0x9;
    const int COM_LATCHF    = 0xA;
    const int COM_READRV    = 0xB;
    const int COM_LATCHRV   = 0xC;

    // constants
    const int REGISTERS = 8;
    const int INDEX_WIDTH = 3;

    // registers
    const int R0    = 0;
    const int R1    = 1;
    const int R2    = 2;
    const int R3    = 3;
    const int R4    = 4;
    const int RV    = 5;
    const int SP    = 6;
    const int F     = 7;
}

#endif

