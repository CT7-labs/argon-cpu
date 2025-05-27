// ALU.v

// ALU opcodes
localparam OP_ADD   = 4'h0;     // Add
localparam OP_SUB   = 4'h1;     // Subtract
localparam OP_AND   = 4'h2;     // Logical AND
localparam OP_OR    = 4'h3;     // Logical OR
localparam OP_NOR   = 4'h4;     // Logical NOR
localparam OP_XOR   = 4'h5;     // Logical XOR
localparam OP_SLL   = 4'h6;     // Shift Left Logical
localparam OP_SRL   = 4'h7;     // Shift Right Logical
localparam OP_SRA   = 4'h8;     // Shift Right Arithmetic
localparam OP_SLT   = 4'h9;     // Set Less Than (signed)
localparam OP_SLTU  = 4'hA;     // Set Less Than (unsigned)
localparam OP_SETB  = 4'hB;     // Set bit
localparam OP_CLRB  = 4'hC;     // Clear bit
localparam OP_RFU1  = 4'hD;     // Reserved for future use
localparam OP_RFU2  = 4'hE;     // Reserved for future use
localparam OP_RFU3  = 4'hF;     // Reserved for future use

module ALU (
    input wire i_clk,
    input wire [3:0]    i_opcode,

    input wire [31:0]   i_wordA,
    input wire [31:0]   i_wordB,
    input wire [4:0]    i_shamt,
    output wire [31:0]   o_result,

    output wire o_flag_equal,
    output wire o_flag_notequal
);

    always_comb begin
        o_flag_equal = i_wordA == i_wordB;
        o_flag_notequal = i_wordA != i_wordB;
    end

    reg debug_invalid_opcode;

    always_comb begin
        debug_invalid_opcode = 0;

        case (i_opcode)
            OP_ADD:     o_result = i_wordA + i_wordB;
            OP_SUB:     o_result = i_wordA - i_wordB;
            OP_AND:     o_result = i_wordA & i_wordB;
            OP_OR:      o_result = i_wordA | i_wordB;
            OP_NOR:     o_result = ~(i_wordA | i_wordB);
            OP_XOR:     o_result = i_wordA ^ i_wordB;
            OP_SLL:     o_result = i_wordA << i_shamt; // SLL == SLA
            OP_SRL:     o_result = i_wordA >> i_shamt;
            OP_SRA:     o_result = i_wordA >>> i_shamt;
            OP_SLT:     o_result = {31'b0, ($signed(i_wordA) < $signed(i_wordB))};
            OP_SLTU:    o_result = {31'b0, (i_wordA < i_wordB)};
            OP_SETB:    o_result = i_wordA | (1 << i_shamt);
            OP_CLRB:    o_result = i_wordA & ~(1 << i_shamt);
            default: begin
                o_result = 32'h0;
                debug_invalid_opcode = 1;
            end
        endcase
    end
    
endmodule