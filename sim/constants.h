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
    const int RFU        = 0x5;
}

namespace ALU {
    namespace OP {
        const int ADD   = 0x0;
        const int ADC   = 0x1;
        const int SBC   = 0x2;
        const int CMP   = 0x3;
        const int INC   = 0x4;
        const int DEC   = 0x5;
        const int NAND  = 0x6;
        const int AND   = 0x7;
        const int OR    = 0x8;
        const int NOR   = 0x9;
        const int XOR   = 0xA;
        const int LSH   = 0xB;
        const int RSH   = 0xC;
        const int RFU   = 0xD;
    }

    namespace FLAG {
        const int CARRY     = 0;
        const int ZERO      = 1;
        const int EQUAL     = 2;
        const int GREATER   = 3;
        const int LESS      = 4;
        const int BORROW    = 5;
        const int RFU       = 6;
    }
}

#endif