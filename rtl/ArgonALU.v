localparam OP_ADD = 0;
localparam OP_SUB = 1;
localparam OP_AND = 2;
localparam OP_OR  = 3;
localparam OP_XOR = 4;
localparam OP_SLL = 5;
localparam OP_SRL = 6;
localparam OP_SLT = 6;

module ArgonALU #(parameter OPWIDTH = 3, DATAWIDTH = 16, FLAGSWIDTH = 8) (
    // Control signals
    input wire i_clk,
    input wire [OPWIDTH-1:0] i_op,
    
    input wire [DATAWIDTH-1:0] i_wordA,
    input wire [DATAWIDTH-1:0] i_wordB,
    output wire [DATAWIDTH-1:0] o_result,
    output wire o_invalidOp
);

    always @(*) begin
        o_invalidOp = 0;

        case (i_op)
            OP_ADD: o_result = i_wordA + i_wordB;
            OP_SUB: o_result = i_wordA - i_wordB;
            OP_AND: o_result = i_wordA & i_wordB;
            OP_OR:  o_result = i_wordA | i_wordB;
            OP_XOR: o_result = i_wordA ^ i_wordB;
            OP_SLL: o_result = i_wordA << i_wordB;
            OP_SRL: o_result = i_wordA >> i_wordB;
            OP_SLT: o_result = (i_wordA < i_wordB) ? 1 : 0;
            default: begin
                o_invalidOp = 1;
                o_result = 0;
            end
        endcase
    end
    
endmodule