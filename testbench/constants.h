#ifndef CONSTANTS_H
#define CONSTANTS_H

const int WORDSIZE = 16;

// bus unit IDs
const int ID_ALU        = 0x1;
const int ID_REGFILE    = 0x2;
const int ID_DEBUG      = 0x3;
const int ID_STACK      = 0x4;

namespace ALU {
    // commands
    const int COM_LATCHOP  = 0x1;
    const int COM_WRITEC   = 0x2;
    const int COM_WRITEF   = 0x3;

    // opcodes
    const int OP_ADD   = 0x0;
    const int OP_ADC   = 0x1;
    const int OP_SUB   = 0x2;
    const int OP_SBB   = 0x3;
    const int OP_CMP   = 0x4;
    const int OP_INC   = 0x5;
    const int OP_DEC   = 0x6;
    const int OP_NAND  = 0x7;
    const int OP_AND   = 0x8;
    const int OP_OR    = 0x9;
    const int OP_NOR   = 0xA;
    const int OP_XOR   = 0xB;
    const int OP_LSH   = 0xC;
    const int OP_RSH   = 0xD;
    const int OP_ROL   = 0xE;
    const int OP_ROR   = 0xF;

    static const char* opnames[] = {
        "ADD",
        "ADC",
        "SUB",
        "SBB",
        "CMP",
        "INC",
        "DEC",
        "NAND",
        "AND",
        "OR",
        "NOR",
        "XOR",
        "LSH",
        "RSH",
        "ROL",
        "ROR"
    };

    // ALU flag constants
    const int F_CARRY   = 1;
    const int F_ZERO    = 1 << 1;
    const int F_EQUAL   = 1 << 2;
    const int F_GREATER = 1 << 3;
    const int F_LESS    = 1 << 4;
    const int F_BORROW  = 1 << 5;
    const int F_ERROR   = 1 << 7;
}

namespace REGFILE {

    // commands
    const int COM_READA     = 0x1;
    const int COM_READB     = 0x2;
    const int COM_LATCHC    = 0x3;
    const int COM_LATCHSEL  = 0x4;
    const int COM_READF     = 0x5;
    const int COM_ALU_WE    = 0x6;
    const int COM_SP_WE     = 0x7;

    // constants
    const int REGISTERS = 8;
    const int INDEX_WIDTH = 3;
}

// registers
const int R_ZERO    = 0;
const int R_GP1     = 1;
const int R_GP2     = 2;
const int R_GP3     = 3;
const int R_GP4     = 4;
const int R_GP5     = 5;
const int R_SP      = 6;
const int R_F       = 7;

namespace STACK {
    // commands

    const int COM_PUSH      = 0x1;
    const int COM_POP       = 0x2;
    const int COM_LOAD_PTR  = 0x3;
    const int COM_READ_PTR  = 0x3;
}

#endif
