package alu_pkg;
    // ALU Commands
    typedef enum logic [3:0] {
        COM_NOP     = 4'h0,  // No operation
        COM_LATCHOP = 4'h1,  // Latch operation
        COM_WRITEC = 4'h2,   // Write result back to C in register file
        COM_WRITEF = 4'h3   // Write result flags back to F in register file
    } alu_command_t;

    // ALU Operations
    typedef enum logic [3:0] {
        ALU_ADD  = 4'h0,  // Add
        ALU_ADC  = 4'h1,  // Add with carry
        ALU_SUB  = 4'h2,  // Subtract
        ALU_SBB  = 4'h3,  // Subtract with borrow
        ALU_CMP  = 4'h4,  // Compare
        ALU_INC  = 4'h5,  // Increment
        ALU_DEC  = 4'h6,  // Decrement
        ALU_NAND = 4'h7,  // NAND
        ALU_AND  = 4'h8,  // AND
        ALU_OR   = 4'h9,  // OR
        ALU_NOR  = 4'hA,  // NOR
        ALU_XOR  = 4'hB,  // XOR
        ALU_LSH  = 4'hC,  // Left shift
        ALU_RSH  = 4'hD,  // Right shift
        ALU_ROL  = 4'hE,  // Rotate left
        ALU_ROR  = 4'hF   // Rotate right
    } alu_op_t;

    // Flag bit positions
    typedef enum int {
        F_CARRY   = 0,  // Carry flag
        F_ZERO    = 1,  // Zero flag
        F_EQUAL   = 2,  // Equal flag
        F_GREATER = 3,  // Greater than flag
        F_LESS    = 4,  // Less than flag
        F_BORROW  = 5,  // Borrow flag
        F_ERROR   = 7   // Error flag
    } flag_pos_t;

    // Optional: packed struct for flags
    typedef struct packed {
        logic       reserved;  // Bit 6
        logic       error;     // Bit 7
        logic       borrow;    // Bit 5
        logic       less;      // Bit 4
        logic       greater;   // Bit 3
        logic       equal;     // Bit 2
        logic       zero;      // Bit 1
        logic       carry;     // Bit 0
    } flags_t;

endpackage