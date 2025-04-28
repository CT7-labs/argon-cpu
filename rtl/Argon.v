module Argon (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // Memory interface
    input wire [31:0] i_memory_data, // 32-bit for single-cycle instruction loads
    output reg [15:0] o_memory_data,
    output reg [15:0] o_memory_address,
    input wire i_memory_idle,
    input wire i_memory_busy,
    output reg o_memory_re,
    output reg o_memory_we
);
    // Clock wire
    wire sys_clk;
    assign sys_clk = (i_clk & ~i_halt);

    // Control unit
    reg [15:0] r_program_counter;
    reg [2:0] r_instruction_stage;
    localparam STEP_IF1 = 3'd0, STEP_IF2 = 3'd1, STEP_ID = 3'd2, STEP_EX = 3'd3, STEP_MEM1 = 3'd4, STEP_MEM2 = 3'd5, STEP_WB = 3'd6;
    
    // === Instruction register and wires ===
    reg [31:0] r_instruction;

    wire [5:0] w_instruction_opcode, w_instruction_funct6;
    wire [3:0] w_instruction_rs1, w_instruction_rs2, w_instruction_rd;
    wire [7:0] w_instruction_imm8;
    wire [15:0] w_instruction_imm16, w_instruction_signed_offset12;
    wire [11:0] w_instruction_offset12;
    assign w_instruction_opcode     = r_instruction[5:0];
    assign w_instruction_rd         = r_instruction[9:6];
    assign w_instruction_rs1        = r_instruction[13:10];
    assign w_instruction_rs2        = r_instruction[17:14];
    assign w_instruction_funct6     = r_instruction[23:18]
    assign w_instruction_imm8       = r_instruction[31:24];

    assign w_instruction_imm16      = r_instruction[31:16];
    assign w_instruction_offset12   = {r_instruction[31:24], r_instruction[9:6]};
    assign w_instruction_signed_offset12 = {
        w_instruction_offset12[11],
        1'b0,
        w_instruction_offset12[10:0],
        2'b00
    };

    wire [15:0] w_program_counter_increment;
    assign w_program_counter_increment = 16'h0004; // PC = PC + 4

    // === Muxing ===
    reg [1:0] r_mux_alu_output;             // 0: Registers, 1: PC, 2: MP, 3: Reserved
    reg       r_mux_registers_writeback;    // 0: ALU result, 1: imm16
    reg       r_mux_alu_selectA;            // 0: Registers portA, 1: PC
    reg [1:0] r_mux_alu_selectB;            // 0: Registers portB, 1: imm16, 2: offset12, 3: +4 constant

    // === Combinational control ===
    // ALU
    assign w_alu_wordA = (r_mux_alu_selectA == 1'b0) ? w_registers_portA : r_program_counter;
    assign w_alu_wordB = (r_mux_alu_selectB == 2'b00) ? w_registers_portB :
                         (r_mux_alu_selectB == 2'b01) ?  :
                         (r_mux_alu_selectB == 2'b10) ? w_instruction_signed_offset12 :
                         (r_mux_alu_selectB == 2'b11) ? w_program_counter_increment;
    
    // Registers
    assign w_registers_portW = (r_mux_registers_writeback == 1'b0) ? w_alu_result : w_instruction_imm16;
    
    // === Module Instantiation ===
    // ALU
    wire [15:0] w_alu_wordA, w_alu_wordB, w_alu_result;
    wire [3:0] w_alu_opcode;
    assign w_alu_opcode = w_instruction_funct6[3:0]
    wire w_alu_flag_zero, w_alu_flag_sign, w_alu_flag_overflow, w_alu_flag_carry;

    ALU inst_alu (
        .i_clk(sys_clk),
        .i_opcode(w_alu_opcode),

        .i_wordA(w_alu_wordA),
        .i_wordB(w_alu_wordB),
        .o_result(w_alu_result),

        .o_flag_zero(w_alu_flag_zero),
        .o_flag_sign(w_alu_flag_sign),
        .o_flag_overflow(w_alu_flag_overflow),
        .o_flag_carry(w_alu_flag_carry)
    );

    // Register File
    wire [15:0] w_registers_portA, w_registers_portB, w_registers_portW;
    wire [3:0] w_registers_selectA, w_registers_selectB, w_registers_selectW;
    reg r_registers_write_en = 1'b0;

    Registers inst_registers (
        .i_clk(sys_clk),
        .i_reset(i_reset),

        // control ports
        .i_write_en(r_registers_write_en),
        .i_selectA(w_instruction_rs1),
        .i_selectB(w_instruction_rs2),
        .i_selectW(w_instruction_rd),

        // data ports
        .o_portA(w_registers_portA),
        .o_portB(w_registers_portB),
        .i_portW(w_registers_portW)
    );
    
    // === Clocked control
    
endmodule