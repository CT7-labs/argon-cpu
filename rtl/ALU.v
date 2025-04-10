// ALU.v

// ALU opcodes
localparam OP_ADD    = 4'h0;    // Add
localparam OP_SUB    = 4'h1;    // Subtract
localparam OP_AND    = 4'h2;    // Logical AND
localparam OP_OR     = 4'h3;    // Logical OR
localparam OP_XOR    = 4'h4;    // Logical XOR
localparam OP_SLL    = 4'h5;    // Shift Left Logical
localparam OP_SRL    = 4'h6;    // Shift Right Logical
localparam OP_SRA    = 4'h7;    // Shift Right Arithmetic
localparam OP_SLT    = 4'h8;    // Set Less Than (signed)
localparam OP_SLTU   = 4'h9;    // Set Less Than (unsigned)

module ALU (
    // control port (yeah pretty simple here)
    input wire [3:0] i_opcode,

    // data ports
    input wire [15:0] i_wordA,
    input wire [15:0] i_wordB,
    output reg [15:0] o_result,

    // flag ports
    output wire o_flag_zero,
    output wire o_flag_sign,
    output wire o_flag_overflow,
    output wire o_flag_carry
);

    always @(*) begin
        case (i_opcode)
            OP_ADD:  o_result = i_wordA + i_wordB;                // Addition
            OP_SUB:  o_result = i_wordA - i_wordB;                // Subtraction
            OP_AND:  o_result = i_wordA & i_wordB;                // Bitwise AND
            OP_OR:   o_result = i_wordA | i_wordB;                // Bitwise OR
            OP_XOR:  o_result = i_wordA ^ i_wordB;                // Bitwise XOR
            OP_SLL:  o_result = i_wordA << i_wordB[3:0];          // Shift Left Logical
            OP_SRL:  o_result = i_wordA >> i_wordB[3:0];          // Shift Right Logical
            OP_SRA:  o_result = $signed(i_wordA) >>> i_wordB[3:0]; // Shift Right Arithmetic
            OP_SLT:  o_result = ($signed(i_wordA) < $signed(i_wordB)) ? 16'h1 : 16'h0; // Signed Less Than
            OP_SLTU: o_result = (i_wordA < i_wordB) ? 16'h1 : 16'h0; // Unsigned Less Than
            default: o_result = 16'h0;                            // Default: output 0
        endcase
    end

    assign o_flag_zero = (o_result == 16'h0);
    assign o_flag_sign = o_result[15];
    assign o_flag_overflow = (i_opcode == OP_ADD) ? 
                             ((i_wordA[15] == i_wordB[15]) && (o_result[15] != i_wordA[15])) :
                             (i_opcode == OP_SUB) ? 
                             ((i_wordA[15] != i_wordB[15]) && (o_result[15] != i_wordA[15])) : 
                             1'b0;
    assign o_flag_carry = (i_opcode == OP_SUB) ? (i_wordA < i_wordB) : 1'b0;

endmodule