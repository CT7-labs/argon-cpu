// ALU.v

// ALU opcodes
parameter ALUOP_ADD   = 4'h0;     // Add
parameter ALUOP_SUB   = 4'h1;     // Subtract
parameter ALUOP_AND   = 4'h2;     // Logical AND
parameter ALUOP_OR    = 4'h3;     // Logical OR
parameter ALUOP_NOR   = 4'h4;     // Logical NOR
parameter ALUOP_XOR   = 4'h5;     // Logical XOR
parameter ALUOP_SLL   = 4'h6;     // Shift Left Logical
parameter ALUOP_SRL   = 4'h7;     // Shift Right Logical
parameter ALUOP_SRA   = 4'h8;     // Shift Right Arithmetic
parameter ALUOP_SLT   = 4'h9;     // Set Less Than (signed)
parameter ALUOP_SLTU  = 4'hA;     // Set Less Than (unsigned)
parameter ALUOP_SETB  = 4'hB;     // Set bit
parameter ALUOP_CLRB  = 4'hC;     // Clear bit
parameter ALUOP_SLLV  = 4'hD;     // Shift left logical (variable)
parameter ALUOP_SRLV  = 4'hE;     // Shift right logical (variable)
parameter ALUOP_SRAV  = 4'hF;     // Shift right arithmetic (variable)

module ALU (
    input wire i_clk,
    input wire [3:0]    i_opcode,

    input logic [31:0]   i_wordA,
    input logic [31:0]   i_wordB,
    input logic [4:0]    i_shamt,
    output logic [31:0]  o_result,

    output logic o_flag_equal,
    output logic o_flag_notequal
);
    logic debug_invalid_opcode;

    always_comb begin
        debug_invalid_opcode = 0;

        case (i_opcode)
            ALUOP_ADD:      o_result = i_wordA + i_wordB;
            ALUOP_SUB:      o_result = i_wordA - i_wordB;
            ALUOP_AND:      o_result = i_wordA & i_wordB;
            ALUOP_OR:       o_result = i_wordA | i_wordB;
            ALUOP_NOR:      o_result = ~(i_wordA | i_wordB);
            ALUOP_XOR:      o_result = i_wordA ^ i_wordB;
            ALUOP_SLL:      o_result = i_wordA << i_shamt; // SLL == SLA
            ALUOP_SRL:      o_result = i_wordA >> i_shamt;
            ALUOP_SRA:      o_result = i_wordA >>> i_shamt;
            ALUOP_SLT:      o_result = {31'b0, ($signed(i_wordA) < $signed(i_wordB))};
            ALUOP_SLTU:     o_result = {31'b0, (i_wordA < i_wordB)};
            ALUOP_SETB:     o_result = i_wordA | (1 << i_shamt);
            ALUOP_CLRB:     o_result = i_wordA & ~(1 << i_shamt);
            ALUOP_SLLV:     o_result = i_wordA << i_wordB[4:0];
            ALUOP_SRLV:     o_result = i_wordA >> i_wordB[4:0];
            ALUOP_SRAV:     o_result = i_wordA >>> i_wordB[4:0];
        endcase

        o_flag_equal = i_wordA == i_wordB;
        o_flag_notequal = i_wordA != i_wordB;
    end
    
endmodule