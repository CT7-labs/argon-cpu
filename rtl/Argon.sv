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
parameter BOOT_INITIAL_STAGE = STAGE_MEM;

module Argon (
    input wire i_clk,
    input wire i_halt,
    input wire i_reset,

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
    initial r_stage = BOOT_INITIAL_STAGE; // should be MEM

    logic [31:0] r_instruction; // Instruction register

    // Raw bit fields
    logic [5:0] w_opcode, w_funct6;
    logic [4:0] w_rs, w_rd, w_rt, w_shamt;
    logic [15:0] w_imm16;
    logic [1:0] r_wb_src;

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

    always_ff @(posedge sys_clk or posedge i_reset) begin
        // debug defaults
        r_debug_invalid_funct6 <= 0;
        r_debug_invalid_opcode <= 0;

        if (i_reset) begin
            r_stage <= BOOT_INITIAL_STAGE;
            r_registers_write_en <= 0;
            r_wb_src <= WBSRC_NONE;
        
            r_registers_selectA <= 0;
            r_registers_selectB <= 0;
            r_registers_selectW <= 0;
            r_alu_shamt <= 0;
        end else begin

            if (r_stage == STAGE_IF) begin // ========== instruction fetch
                r_stage <= STAGE_ID;

                // Prevent broken writes
                r_registers_write_en <= 0;

                // instruction fetch
                r_instruction <= i_mem_rd_data;

                // PC increment
                r_alu_wordA <= r_pc;
                r_alu_wordB <= w_pc_inc;
                r_alu_opcode <= ALUOP_ADD;
            
            end else if (r_stage == STAGE_ID) begin // ============ instruction decode
                r_stage <= STAGE_EX;

                // Select register ports
                r_registers_selectA <= w_rs;
                r_registers_selectB <= w_rt;
                if (w_opcode == 18) r_registers_selectW <= 27; // Return Address (ra)
                else r_registers_selectW <= w_rd;

                // PC increment
                // new PC is latched to r_alu_result

            end else if (r_stage == STAGE_EX) begin // =============== execute
                r_stage <= STAGE_MEM;

                // Latch new sources into ALU
                if (w_opcode == 1) begin
                    r_alu_wordA <= r_registers_portA;
                    r_alu_wordB <= r_registers_portB;
                    r_alu_shamt <= w_shamt;

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
                        default: r_debug_invalid_funct6 <= 1;
                    endcase

                    if (w_funct6 < 16) r_wb_src <= WBSRC_ALU;
                    else r_wb_src <= WBSRC_NONE;

                end else if (w_opcode >= 2 && w_opcode <= 10) begin // Immediate ALU opcodes
                    r_alu_wordA <= r_registers_portA;
                    r_alu_wordB <= w_zero_ext_imm;

                    case (w_opcode)
                        6'h2: r_alu_opcode <= ALUOP_ADD;
                        6'h3: r_alu_opcode <= ALUOP_SUB;
                        6'h4: r_alu_opcode <= ALUOP_AND;
                        6'h5: r_alu_opcode <= ALUOP_OR;
                        6'h6: r_alu_opcode <= ALUOP_NOR;
                        6'h7: r_alu_opcode <= ALUOP_XOR;
                    endcase

                    r_wb_src <= WBSRC_ALU;
                end else if (w_opcode == 8 || w_opcode == 9) begin
                    // handle branch opcodes

                    r_wb_src <= WBSRC_NONE;
                end else if (w_opcode == 10) begin
                    r_wb_src <= WBSRC_UPPER_IMM;
                end else if (w_opcode >= 11 && w_opcode <= 16) begin
                    // handle load/store opcodes

                    o_mem_addr <= r_registers_portA;
                    o_mem_wr_data <= r_registers_portB;
                    case (w_opcode)
                        6'h14: o_mem_wr_mask <= WRMASK_W;
                        6'h15: o_mem_wr_mask <= WRMASK_H;
                        6'h16: o_mem_wr_mask <= WRMASK_B;
                        default: o_mem_wr_mask <= WRMASK_N;
                    endcase

                    r_wb_src <= WBSRC_NONE;
                end else if (w_opcode == 17 || w_opcode == 18) begin
                    r_wb_src <= WBSRC_NONE;
                end else begin
                    r_debug_invalid_opcode <= 1;

                    r_wb_src <= WBSRC_NONE;
                end

                // PC increment
                if (w_opcode == 17) begin
                    $display("test", w_jump_target >> 2);
                    r_pc <= w_jump_target;
                end if (w_opcode == 18) begin
                    r_registers_portW <= r_pc;
                    r_registers_write_en <= 1;
                    r_pc <= w_jump_target;
                end else begin
                   r_pc <= r_alu_result;
                end
            
            end else if (r_stage == STAGE_MEM) begin // ============ memory
                r_stage <= STAGE_WB;

                // ALU output is latched
                case (w_opcode)
                    6'h11: o_mem_rd_mask <= RDMASK_W;
                    6'h12: o_mem_rd_mask <= RDMASK_HE;
                    6'h13: o_mem_rd_mask <= RDMASK_BE;
                    default: o_mem_rd_mask <= RDMASK_XX;
                endcase

                if (w_opcode == 18) begin
                    r_registers_write_en <= 0;
                end

                // instruction fetch
                o_mem_addr <= r_pc;
                $display(r_pc);
            end else if (r_stage == STAGE_WB) begin // ============= writeback
                r_stage <= STAGE_IF;

                // ALU output has been written to register file
                case (r_wb_src)
                    WBSRC_NONE: begin
                        if (w_opcode == 1 && w_funct6 == 6'd16) begin // jmpr mnemonic
                            o_mem_addr <= r_registers_portA;
                        end else if (w_opcode == 1 && w_funct6 == 6'd17) begin //jalr mnemonic
                            o_mem_addr <= r_registers_portA;
                            r_registers_portW <= r_pc;
                            r_registers_write_en <= 1; // yes, definitely confusing given it's location
                            r_stage <= STAGE_FD;
                        end else if (w_opcode == 17 || w_opcode == 18) begin
                            // jmp and jal mnemonics
                        end
                    end
                    WBSRC_ALU: begin
                        r_registers_portW <= r_alu_result;
                        r_registers_write_en <= 1;
                    end
                    WBSRC_MEM: begin
                        // not implemented
                    end
                    WBSRC_UPPER_IMM: begin
                        r_registers_portW <= w_lui_imm;
                        r_registers_write_en <= 1;
                    end
                endcase

                r_wb_src <= WBSRC_NONE; // we're done writing

                // instruction fetch
                o_mem_rd_mask <= RDMASK_W;
            end else if (r_stage == STAGE_FD) begin
                r_stage <= STAGE_IF;

                o_mem_rd_mask <= RDMASK_W;
            end
        end
        

    end

    // RegisterFile instantiation
    logic r_registers_write_en;
    logic [4:0] r_registers_selectA, r_registers_selectB, r_registers_selectW;
    logic [31:0] r_registers_portA, r_registers_portB, r_registers_portW;
    
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