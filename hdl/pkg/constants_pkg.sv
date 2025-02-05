package constants_pkg;
    // Core CPU parameters
    parameter WORDSIZE       = 16;
    parameter COMMAND_WIDTH  = 4;
    parameter ERROR_WIDTH    = 4;

    // Common types
    typedef logic [WORDSIZE-1:0] word_t;
    typedef logic [COMMAND_WIDTH-1:0] command_t;

    // Bus unit IDs
    typedef enum command_t {
        ID_ALU     = 4'h1,
        ID_REGFILE = 4'h2,
        ID_DEBUG   = 4'h3,
        ID_STACK   = 4'h4
    } unit_id_t;

    // Error codes
    typedef enum logic [ERROR_WIDTH-1:0] {
        ERROR_NONE           = '0,
        ERROR_INVALID_INPUT  = '1
    } error_t;

endpackage