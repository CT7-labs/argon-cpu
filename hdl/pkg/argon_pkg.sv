// package for Argon v1.5

package argon_pkg;
    // parameters
    parameter WORDSIZE = 16;
    parameter REGISTERS = 16;

    // types
    typedef logic [WORDSIZE-1: 0] word_t;

    // bus unit IDs
    parameter ID_ALU       = 4'h1;
    parameter ID_REGFILE   = 4'h2;
    parameter ID_DEBUG     = 4'h3;
    parameter ID_RFU       = 4'h4; // reserved for future use
    // and so on...

endpackage
