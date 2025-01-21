// package for Argon v1.5

package argon_pkg;
    // parameters
    parameter WORDSIZE = 16;
    parameter REGISTERS = 16;

    // types
    typedef logic [WORDSIZE-1: 0] word_t;

    // ALU operation constants
    parameter ALU_ADD        = 4'h0;
    parameter ALU_ADC        = 4'h1;
    parameter ALU_SBC        = 4'h2;
    parameter ALU_CMP        = 4'h3;
    parameter ALU_INC        = 4'h4;
    parameter ALU_DEC        = 4'h5;
    parameter ALU_NAND       = 4'h6;
    parameter ALU_AND        = 4'h7;
    parameter ALU_OR         = 4'h8;
    parameter ALU_NOR        = 4'h9;
    parameter ALU_XOR        = 4'hA;
    parameter ALU_LSH        = 4'hB;
    parameter ALU_RSH        = 4'hC;
    parameter ALU_RFU1        = 4'hD; // reserved for future use
    parameter ALU_RFU2        = 4'hE; // reserved for future use
    parameter ALU_RFU3        = 4'hF; // reserved for future use

    // ALU flag constants
    parameter F_CARRY       = 0;
    parameter F_ZERO        = 1;
    parameter F_EQUAL       = 2;
    parameter F_GREATER     = 3;
    parameter F_LESS        = 4;
    parameter F_BORROW      = 5; // not 100% necessary
    parameter F_RFU1         = 6; // reserved for future use
    parameter F_RFU2         = 7; // reserved for future use

endpackage
