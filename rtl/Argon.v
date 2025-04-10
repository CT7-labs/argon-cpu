module Argon (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // Sim controls
    input wire i_write_to_regfile,
    input wire i_use_immediate,

    // Register File Wires
    output wire [15:0] o_portA,
    output wire [15:0] o_portB,
    input wire [15:0] i_portW,

    input wire i_write_en,
    input wire [3:0] i_selectA,
    input wire [3:0] i_selectB,
    input wire [3:0] i_selectW,

    // ALU wires
    input wire [3:0] i_alu_op,
    output wire o_flag_zero,
    output wire o_flag_sign,
    output wire o_flag_overflow,
    output wire o_flag_carry
);

    // wires
    wire sys_clk;
    assign sys_clk = (i_clk & ~i_halt);

    wire [15:0] w_alu_operandB;
    wire [15:0] w_alu_result;

    assign w_registers_writeback = (i_write_to_regfile) ? i_portW : w_alu_result;
    assign w_operandB = (i_use_immediate) ? i_portW : o_portB;

    wire [15:0] w_registers_portA, w_registers_portB, w_registers_writeback;
    Registers inst_argon_registers (
        .i_clk(sys_clk),
        .i_reset(i_reset),

        .i_write_en(i_write_en),
        .i_selectA(i_selectA),
        .i_selectB(i_selectB),
        .i_selectW(i_selectW),

        .o_portA(o_portA),
        .o_portB(o_portB),
        .i_portW(w_registers_writeback)
    );

    ALU inst_argon_alu (
        .i_opcode(i_alu_op),

        .i_wordA(w_registers_portA),
        .i_wordB(w_alu_operandB),
        .o_result(w_alu_result),

        .o_flag_zero(o_flag_zero),
        .o_flag_sign(o_flag_sign),
        .o_flag_overflow(o_flag_overflow),
        .o_flag_carry(o_flag_carry)
    );
    
endmodule