// package for Argon v1.5

package constants_pkg;
    // parameters
    parameter WORDSIZE = 16;
    parameter COMMAND_WIDTH = 4;

    // types
    typedef logic [WORDSIZE-1: 0] word_t;

    // bus unit IDs
    parameter ID_ALU        = 4'h1;
    parameter ID_REGFILE    = 4'h2;
    parameter ID_DEBUG      = 4'h3;
    parameter ID_STACK      = 4'h4;
    // and so on...

endpackage
