module Argon (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // Memory interface
    input wire [31:0] i_memory_data, // 32-bit for single-cycle instruction loads
    output reg [31:0] o_memory_data,
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
    reg [31:0] r_instruction;

    wire [5:0] w_opcode, w_funct6;
    wire [3:0] w_rs1, w_rs2, w_rd;
    wire [7:0] w_imm8;
    wire [15:0] w_imm16;
    wire [11:0] w_offset12;
    assign w_instruction_opcode     = r_instruction[5:0];
    assign w_instruction_rd         = r_instruction[9:6];
    assign w_instruction_rs1        = r_instruction[13:10];
    assign w_instruction_rs2        = r_instruction[17:14];
    assign w_instruction_imm8       = r_instruction[31:24];
    assign w_instruction_imm16      = r_instruction[31:16];
    assign w_instruction_offset12   = {r_instruction[31:24], r_instruction[9:6]};

    // === Muxing ===
    localparam MUX_ALUTOREGISTERS = 2'h1;
    reg [1:0] r_mux_alu_output;

    // === Combinational control ===

    // Defines where 
    assign w_registers_writeback = (r_mux_alu_output == MUX_ALUTOREG) ? w_alu_result : 0;

    // === Clocked control ===
    always @(posedge sys_clk or posedge i_reset) begin
        if (i_reset) begin
            // Control unit reset
            r_program_counter <= 0;
            r_instruction_stage <= STEP_IF1;
            o_memory_re <= 0;
            o_memory_we <= 0;

            // Mux control reset
            r_mux_alu_output <= 0;

        end else begin
            if (r_instruction_stage == STEP_IF1) begin
                o_memory_address <= r_program_counter;
                o_memory_re <= 1;
                o_memory_we <= 0;

                r_instruction_stage <= STEP_IF2;
            end else if (r_instruction_stage == STEP_IF2) begin
                if (~i_memory_busy) begin
                    o_memory_address <= 0;
                    o_memory_re <= 0;
                    o_memory_we <= 0;
                    r_instruction <= i_memory_data;

                    r_instruction_stage <= STEP_ID;
                end

                // do nothing, we're waiting on the memory unit to get back to us with data
            end else if (r_instruction_stage == STEP_ID) begin
                // Register/register opcodes (8)
                if (w_instruction_opcode < 8) begin
                    r_alu_op <= w_funct6[3:0];
                    r_registers_selectA <= w_rs1;
                    r_registers_selectB <= w_rs2;
                    r_registers_selectW <= w_rd;

                    r_mux_alu_output <= MUX_ALUTOREGISTERS;

                    r_instruction_stage <= STEP_EX;
                end

                // Immediate opcodes (8)

                // Branch opcodes (8)

                // Store opcodes (8)

                // Reserved opcodes (32)
            end else if (r_instruction_stage == STEP_EX) begin
                // Register/register opcodes (8)
                if (w_instruction_opcode < 8) begin
                    r_alu_operandA <= w_registers_portA;
                    r_alu_operandB <= w_registers_portB;

                    r_registers_write_en <= 1; // used by WB step

                    r_instruction_stage <= STEP_WB;
                end

                // Immediate opcodes (8)

                // Branch opcodes (8)

                // Store opcodes (8)

                // Reserved opcodes (32)
            end else if (r_instruction_stage == STEP_WB) begin
                // Register/register opcodes (8)
                if (w_instruction_opcode < 8) begin
                    r_mux_alu_output <= 0;

                    r_instruction_stage <= STEP_IF1;
                end

                // Immediate opcodes (8)

                // Branch opcodes (8)

                // Store opcodes (8)

                // Reserved opcodes (32)
            end
        end
    end

    // Modules

    reg [3:0] r_registers_selectA, r_registers_selectB, r_registers_selectW;
    reg r_registers_write_en;
    wire [15:0] w_registers_portA, w_registers_portB
    Registers inst_argon_registers (
        .i_clk(sys_clk),
        .i_reset(i_reset),

        .i_write_en(r_registers_write_en),
        .i_selectA(r_registers_selectA),
        .i_selectB(r_registers_selectB),
        .i_selectW(r_registers_selectW),

        .o_portA(w_registers_portA),
        .o_portB(w_registers_portB),
        .i_portW(w_registers_writeback)
    );

    reg [15:0] r_alu_operandA, r_alu_operandB;
    wire [15:0] w_alu_result;
    reg [3:0] r_alu_op;
    wire w_flag_zero, w_flag_sign, w_flag_overflow, w_flag_carry;
    ALU inst_argon_alu (
        .i_opcode(r_alu_op),

        .i_wordA(r_alu_operandA),
        .i_wordB(r_alu_operandB),
        .o_result(w_alu_result),

        .o_flag_zero(w_flag_zero),
        .o_flag_sign(w_flag_sign),
        .o_flag_overflow(w_flag_overflow),
        .o_flag_carry(w_flag_carry)
    );
    
endmodule