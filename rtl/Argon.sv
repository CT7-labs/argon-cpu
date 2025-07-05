// Stages for the control FSM
parameter STAGE_IF      = 0;
parameter STAGE_ID      = 1;
parameter STAGE_EX      = 2;
parameter STAGE_MEM     = 3;
parameter STAGE_WB      = 4;
parameter STAGE_FD      = 5; // fetch delay after a branch/jump

// Writeback source constants
parameter WB_SRC_NONE   = 0;
parameter WB_SRC_ALU    = 1;
parameter WB_SRC_LUI    = 2;
parameter WB_SRC_MEM    = 3;

// ALU source constants
parameter ALU_SRC_A_REG     = 0;
parameter ALU_SRC_A_PC      = 1;

parameter ALU_SRC_B_REG     = 0;
parameter ALU_SRC_B_IMM16   = 1;
parameter ALU_SRC_B_PC_INC  = 2;
parameter ALU_SRC_B_BRANCH  = 3;

parameter IMM16_ZERO_EXT    = 0;
parameter IMM16_SIGN_EXT    = 1;

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
    initial r_stage <= BOOT_INITIAL_STAGE;

    logic [31:0] r_instruction; // Instruction register

    // Raw bit fields
    logic [5:0] w_opcode, w_funct6;
    logic [4:0] w_rs, w_rd, w_rt, w_shamt;
    logic [15:0] w_imm16;
    logic [1:0] mux_wb_src;

    assign w_opcode = r_instruction[5:0];       // instruction opcode
    assign w_rs     = r_instruction[10:6];      // source register A
    assign w_rd     = r_instruction[15:11];     // dest. register
    assign w_rt     = r_instruction[20:16];     // source register B
    assign w_shamt  = r_instruction[25:21];     // shift amount
    assign w_funct6 = r_instruction[31:26];     // 6-bit function
    assign w_imm16  = r_instruction[31:16];     // 16-bit immediate

    // Operands
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

    // assignments
    logic r_mux_mem_addr;
    assign o_mem_addr = (r_mux_mem_addr == 0) ? r_pc : r_alu_result;

    always_ff @(posedge sys_clk or posedge i_reset) begin
        // debug defaults

        if (r_stage == STAGE_IF) begin
            r_instruction <= i_mem_rd_data;

            // setup for decode stage
            r_stage <= STAGE_ID;
        end

        if (r_stage == STAGE_ID) begin
            // ALU opcodes
            if (w_opcode == 0) begin
                
            end else if (w_opcode == 1 && w_funct6 < 16) begin
                // R-type arithmetic/bitwise
                mux_alu_srcA <= ALU_SRC_A_REG;
                mux_alu_srcB <= ALU_SRC_B_REG;
                mux_wb_src <= WB_SRC_ALU;

                case (w_funct6)
                    6'h0: r_alu_opcode <= ALUOP_ADD;
                    6'h1: r_alu_opcode <= ALUOP_SUB;
                    6'h2: r_alu_opcode <= ALUOP_AND;
                    6'h3: r_alu_opcode <= ALUOP_OR;
                    6'h4: r_alu_opcode <= ALUOP_NOR;
                    6'h5: r_alu_opcode <= ALUOP_XOR;
                    6'h6: r_alu_opcode <= ALUOP_SETB;
                    6'h7: r_alu_opcode <= ALUOP_CLRB;
                    6'h8: r_alu_opcode <= ALUOP_SLL;
                    6'h9: r_alu_opcode <= ALUOP_SRL;
                    6'hA: r_alu_opcode <= ALUOP_SRA;
                    6'hB: r_alu_opcode <= ALUOP_SLLV;
                    6'hC: r_alu_opcode <= ALUOP_SRLV;
                    6'hD: r_alu_opcode <= ALUOP_SRAV;
                    6'hE: r_alu_opcode <= ALUOP_SLT;
                    6'hF: r_alu_opcode <= ALUOP_SLTU;
                endcase
            end else if (w_opcode < 4) begin
                // immediate arithmetic
                mux_alu_srcA <= ALU_SRC_A_REG;
                mux_alu_srcB <= ALU_SRC_B_IMM16;
                mux_imm16 <= IMM16_SIGN_EXT;
                mux_wb_src <= WB_SRC_ALU;

                case (w_opcode)
                    6'h2: r_alu_opcode <= ALUOP_ADD;
                    6'h3: r_alu_opcode <= ALUOP_SUB;
                endcase
            end else if (w_opcode < 8) begin
                // immediate bitwise
                mux_alu_srcA <= ALU_SRC_A_REG;
                mux_alu_srcB <= ALU_SRC_B_IMM16;
                mux_imm16 <= IMM16_ZERO_EXT;
                mux_wb_src <= WB_SRC_ALU;

                case (w_opcode)
                    6'h4: r_alu_opcode <= ALUOP_AND;
                    6'h5: r_alu_opcode <= ALUOP_OR;
                    6'h6: r_alu_opcode <= ALUOP_NOR;
                    6'h7: r_alu_opcode <= ALUOP_XOR;
                endcase
            end else if (w_opcode < 10) begin
                // BEQ and BNE
                mux_wb_src <= WB_SRC_NONE;

            end else if (w_opcode == 10) begin
                // lui
                mux_wb_src <= WB_SRC_LUI;
            end
            
            // setup for execute stage
            r_stage <= STAGE_EX;
        end

        if (r_stage == STAGE_EX) begin
            // ALU output is valid now
            r_alu_result <= w_alu_output;
            r_alu_opcode <= ALUOP_ADD;
            mux_alu_srcA <= ALU_SRC_A_PC;
            mux_alu_srcB <= ALU_SRC_B_PC_INC;
            
            // setup for memory stage
            r_stage <= STAGE_MEM;
        end

        if (r_stage == STAGE_MEM) begin
            // instruction fetch
            r_mux_mem_addr <= 0; // select PC as memory address source

            // Setup for latching new PC
            r_pc <= w_alu_output;

            // setup for writeback stage
            r_stage <= STAGE_WB;
            if (mux_wb_src != WB_SRC_NONE) r_registers_write_en <= 1;

        end
        
        if (r_stage == STAGE_WB) begin
            // instruction fetch
            o_mem_rd_mask <= RDMASK_W; // read mask latched into memory
            // address is latched into memory

            // writeback is done sooo
            r_registers_write_en <= 0;
            
            // next stage
            r_stage <= STAGE_IF;
        end
    end

    // RegisterFile instantiation
    logic r_registers_write_en;
    logic [4:0] w_registers_selectA, w_registers_selectB, w_registers_selectW;
    logic [31:0] w_registers_portA, w_registers_portB, w_registers_portW;
    logic [31:0] r_alu_result; // intermediate for storing result while computing next PC

    assign w_registers_selectA = w_rs;
    assign w_registers_selectB = w_rt;
    assign w_registers_selectW = w_rd;
    
    always_comb begin
        case (mux_wb_src)
            WB_SRC_NONE:    w_registers_portW = 32'h00000000;
            WB_SRC_ALU:     w_registers_portW = r_alu_result;
            WB_SRC_LUI:     w_registers_portW = w_lui_imm;
            WB_SRC_MEM:     w_registers_portW = i_mem_rd_data;
        endcase
    end 
    
    RegisterFile registerfile_inst (
        .i_clk(sys_clk),
        .i_reset(i_reset),
        .i_write_en(r_registers_write_en),

        .i_selectA(w_registers_selectA),
        .i_selectB(w_registers_selectB),
        .i_selectW(w_registers_selectW),

        .o_portA(w_registers_portA),
        .o_portB(w_registers_portB),
        .i_portW(w_registers_portW)
    );

    // ALU instantiation
    logic mux_alu_srcA, mux_imm16;
    logic [1:0] mux_alu_srcB;
    logic [3:0] r_alu_opcode;
    logic [31:0] w_alu_wordA, w_alu_wordB, w_alu_output;
    logic w_alu_flag_equal, w_alu_flag_notequal;

    // ALU input multiplexing
    always_comb begin
        case (mux_alu_srcA)
            ALU_SRC_A_REG:  w_alu_wordA = r_pc;
            ALU_SRC_A_PC:   w_alu_wordB = w_registers_portA;
        endcase

        case (mux_alu_srcB)
            ALU_SRC_B_REG:      w_alu_wordB = w_registers_portB;
            ALU_SRC_B_IMM16:    w_alu_wordB = (mux_imm16) ? w_sign_ext_imm : w_zero_ext_imm;
            ALU_SRC_B_BRANCH:   w_alu_wordB = w_branch_offset;
        endcase
    end

    ALU alu_inst (
        .i_clk(sys_clk),
        .i_opcode(r_alu_opcode),
        .i_shamt(w_shamt), // direct from instruction register

        .i_wordA(w_alu_wordA),
        .i_wordB(w_alu_wordB),
        .o_output(w_alu_output),

        .o_flag_equal(w_alu_flag_equal),
        .o_flag_notequal(w_alu_flag_notequal)
    );
    
endmodule