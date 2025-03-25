// ALU ops
localparam OP_ADD = 0;
localparam OP_SUB = 1;
localparam OP_AND = 2;
localparam OP_OR  = 3;
localparam OP_XOR = 4;
localparam OP_SLL = 5;
localparam OP_SRL = 6;
localparam OP_SLT = 7;
localparam OP_SLTU = 8;

localparam OP_BEQ = 10;
localparam OP_BNE = 11;
localparam OP_BGE = 12;
localparam OP_BLT = 13;
localparam OP_BGEU = 14;
localparam OP_BLTU = 15;

// Implement branch comparisons as the same ops, but for branch outputs

module ArgonALU #(parameter OPWIDTH = 4, DATAWIDTH = 16, FLAGSWIDTH = 8) (
    // Control signals
    input wire [OPWIDTH-1:0] i_op,
    
    input wire [DATAWIDTH-1:0] i_wordA,
    input wire [DATAWIDTH-1:0] i_wordB,
    output reg [DATAWIDTH-1:0] o_result,
    output reg o_invalidOp,
    output reg o_branchTaken
);

    always @(*) begin
        o_invalidOp = 0;
        o_result = 0;
        o_branchTaken = 0;

        case (i_op)
            // Arithmetic operations
            OP_ADD: o_result = i_wordA + i_wordB;
            OP_SUB: o_result = i_wordA - i_wordB;
            OP_AND: o_result = i_wordA & i_wordB;
            OP_OR:  o_result = i_wordA | i_wordB;
            OP_XOR: o_result = i_wordA ^ i_wordB;
            OP_SLL: o_result = i_wordA << i_wordB;
            OP_SRL: o_result = i_wordA >> i_wordB;
            OP_SLT: o_result = ($signed(i_wordA) < $signed(i_wordB)) ? 1 : 0;
            OP_SLTU: o_result = (i_wordA < i_wordB) ? 1 : 0;

            // Branch comparisons
            OP_BEQ: o_branchTaken = i_wordA == i_wordB;
            OP_BNE: o_branchTaken = i_wordA != i_wordB;
            OP_BGE: o_branchTaken = $signed(i_wordA) >= $signed(i_wordB);
            OP_BLT: o_branchTaken = $signed(i_wordA) < $signed(i_wordB);
            OP_BGEU: o_branchTaken = i_wordA >= i_wordB;
            OP_BLTU: o_branchTaken = i_wordA < i_wordB;

            default: begin
                o_invalidOp = 1;
                o_result = 0;
                o_branchTaken = 0;
            end
        endcase
    end
    
endmodule