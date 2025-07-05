// Stages for the control FSM
parameter STAGE_IF      = 0;
parameter STAGE_ID      = 1;
parameter STAGE_EX      = 2;
parameter STAGE_MEM     = 3;
parameter STAGE_WB      = 4;
parameter STAGE_FD      = 5; // fetch delay after a branch/jump

// Writeback source constants
parameter WBSRC_NONE        = 0;
parameter WBSRC_ALU         = 1;
parameter WBSRC_UPPER_IMM   = 2;
parameter WBSRC_MEM         = 3;

// Boot defaults
parameter BOOT_INITIAL_STAGE = STAGE_WB;

module Argon (
    input logic i_clk,
    input logic i_halt,
    input logic i_reset,

    input logic [31:0] i_mem_rd_data,
    output logic [31:0] o_mem_addr, o_mem_wr_data,
    output logic [2:0] o_mem_rd_mask,
    output logic [1:0] o_mem_wr_mask
);

    // system clock
    wire sys_clk;
    assign sys_clk = i_clk & ~i_halt;

    // ======== Control unit FSM ========
    logic [31:0] r_pc; // program counter
    logic [31:0] w_pc_inc;
    assign w_pc_inc = 32'h4;

    logic [2:0] r_stage;
    initial r_stage <= BOOT_INITIAL_STAGE; // should be MEM

    logic [31:0] r_instruction; // Instruction register

    // Raw bit fields
    logic [5:0] w_opcode, w_funct6;
    logic [4:0] w_rs, w_rd, w_rt, w_shamt;
    logic [15:0] w_imm16;

    assign w_opcode = r_instruction[5:0];       // instruction opcode
    assign w_rs     = r_instruction[10:6];      // source register A
    assign w_rd     = r_instruction[15:11];     // dest. register
    assign w_rt     = r_instruction[20:16];     // source register B
    assign w_shamt  = r_instruction[25:21];     // shift amount
    assign w_funct6 = r_instruction[31:26];     // 6-bit function
    assign w_imm16  = r_instruction[31:16];     // 16-bit immediate

    // Useful operands

    logic [31:0] w_sign_ext_imm;
    logic [31:0] w_zero_ext_imm;
    logic [31:0] w_lui_imm;
    logic [31:0] w_branch_offset;
    logic [25:0] w_jtarg26;
    logic [31:0] w_jump_target;

    assign w_sign_ext_imm = {{16{w_imm16[15]}}, w_imm16};
    assign w_zero_ext_imm = {16'b0, w_imm16};
    assign w_lui_imm = {w_imm16, 16'h0000}; // 32-bit immediate for loading into registers
    assign w_branch_offset = {{14{w_imm16[13]}}, w_imm16, 2'b00}; // 32-bit offset immediate for branching
    assign w_jtarg26  = r_instruction[31:6];   // 26-bit jump target
    assign w_jump_target = {r_pc[31:28], w_jtarg26, 2'b0}; // 32-bit jump address

    // Debug flags
    logic r_debug_invalid_funct6;
    logic r_debug_invalid_opcode;

    // assignments
    logic r_mux_mem_addr;
    assign o_mem_addr == (r_mux_mem_addr == 0) ? r_pc : w_alu_result

    always_ff @(posedge sys_clk or posedge i_reset) begin
        // debug defaults

        if (r_stage == STAGE_IF) begin
            r_instruction <= i_mem_rd_data;

            // setup for decode stage
            r_stage <= STAGE_ID;
        end

        if (r_stage == STAGE_ID) begin
            
            // setup for execute stage
            r_stage <= STAGE_EX;
        end

        if (r_stage == STAGE_EX) begin
            
            // setup for memory stage
            r_stage <= STAGE_MEM;
        end

        if (r_stage == STAGE_MEM) begin
            // instruction fetch
            r_mux_mem_addr <= 0; // select PC as memory address source

            // setup for writeback stage
            r_stage <= STAGE_WB;

        end
        
        if (r_stage == STAGE_WB) begin
            // instruction fetch
            o_mem_rd_mask <= RDMASK_W; // read mask latched into memory
            // address is latched into memory

            // next stage
            r_stage <= STAGE_IF;
        end
    end

    // RegisterFile instantiation
    logic r_registers_write_en;
    logic [4:0] r_registers_selectA, r_registers_selectB, r_registers_selectW;
    logic [31:0] r_registers_portA, r_registers_portB, r_registers_portW;

    assign r_registers_selectA = w_rs;
    assign r_registers_selectB = w_rt;
    assign r_registers_selectW = w_rd;
    assign r_registers_portW = w_alu_result;
    
    RegisterFile registerfile_inst (
        .i_clk(sys_clk),
        .i_reset(i_reset),
        .i_write_en(r_registers_write_en),

        .i_selectA(r_registers_selectA),
        .i_selectB(r_registers_selectB),
        .i_selectW(r_registers_selectW),

        .o_portA(r_registers_portA),
        .o_portB(r_registers_portB),
        .i_portW(r_registers_portW)
    );

    // ALU instantiation
    logic r_alu_srcA;
    logic [1:0] r_alu_srcB;
    logic [3:0] r_alu_opcode;
    logic [4:0] r_alu_shamt;
    logic [31:0] r_alu_wordA, r_alu_wordB, r_alu_result;
    logic w_alu_flag_equal, w_alu_flag_notequal;

    ALU alu_inst (
        .i_clk(sys_clk),
        .i_opcode(r_alu_opcode),
        .i_shamt(r_alu_shamt),

        .i_wordA(r_alu_wordA),
        .i_wordB(r_alu_wordB),
        .o_result(r_alu_result),

        .o_flag_equal(w_alu_flag_equal),
        .o_flag_notequal(w_alu_flag_notequal)
    );
    
endmodule