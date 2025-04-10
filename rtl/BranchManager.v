localparam BEQ      = 6'h0;
localparam BNE      = 6'h1;
localparam BGE      = 6'h2;
localparam BGEU     = 6'h3;
localparam BLT      = 6'h4;
localparam BLTU     = 6'h5;

module BranchManager (
    input wire [5:0] i_branch_type,
    input wire i_flag_zero,
    input wire i_flag_sign,
    input wire i_flag_overflow,
    input wire i_flag_carry,

    output reg o_take_branch
);

    always @(*) begin
        case (i_branch_type)
            BEQ:    o_take_branch = (i_flag_zero);     // Branch if equal
            BNE:    o_take_branch = ~(i_flag_zero);    // Branch if not equal
            BGE:    o_take_branch = (i_flag_sign == i_flag_overflow);   // Branch if A > B (signed) 
            BGEU:   o_take_branch = i_flag_carry;                       // Branch if A > B (unsigned)
            BLT:    o_take_branch = (i_flag_sign != i_flag_overflow);   // Branch if A < B (signed)
            BLTU:   o_take_branch = ~i_flag_carry;                      // Branch if A < B (unsigned)
            default: o_take_branch = 0;
        endcase
    end
    
endmodule