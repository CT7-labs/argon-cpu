package alu_pkg;
    // ALU input command constants

    // 0 is NOP
    parameter COM_LATCHA    = 4'h1;
    parameter COM_LATCHB    = 4'h2;
    parameter COM_LATCHF    = 4'h3;
    parameter COM_LATCHOP   = 4'h4;
    parameter COM_OUTPUTY   = 4'h5;
    parameter COM_OUTPUTF   = 4'h6;
    parameter COM_COMPUTE   = 4'h7;

    // ALU operation constants (4-bit opcode for now)
    parameter ALU_ADD        = 4'h0;
    parameter ALU_ADC        = 4'h1;
    parameter ALU_SUB        = 4'h2;
    parameter ALU_SBB        = 4'h3;
    parameter ALU_CMP        = 4'h4;
    parameter ALU_INC        = 4'h5;
    parameter ALU_DEC        = 4'h6;
    parameter ALU_NAND       = 4'h7;
    parameter ALU_AND        = 4'h8;
    parameter ALU_OR         = 4'h9;
    parameter ALU_NOR        = 4'hA;
    parameter ALU_XOR        = 4'hB;
    parameter ALU_LSH        = 4'hC;
    parameter ALU_RSH        = 4'hD;
    parameter ALU_ROL        = 4'hE;
    parameter ALU_ROR        = 4'hF;

    // ALU flag constants
    parameter F_CARRY       = 0;
    parameter F_ZERO        = 1;
    parameter F_EQUAL       = 2;
    parameter F_GREATER     = 3;
    parameter F_LESS        = 4;
    parameter F_BORROW      = 5;
    parameter F_ERROR       = 7;
endpackage