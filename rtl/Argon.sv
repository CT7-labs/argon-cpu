parameter STAGE_IF      = 0;
parameter STAGE_ID      = 1;
parameter STAGE_EX      = 2;
parameter STAGE_MEM     = 3;
parameter STAGE_WB      = 4;

// ALU source constants
parameter ALUSRCA_REG       = 0;
parameter ALUSRCA_PC        = 1;
parameter ALUSRCB_REG       = 0;
parameter ALUSRCB_IMM16     = 1;
parameter ALUSRCB_PC_INC    = 2;
parameter ALUSRCB_BRANCH    = 3;

// Writeback source constants
parameter WBSRC_ALU         = 0;
parameter WBSRC_EXT_IMM     = 1;
parameter WBSRC_UPPER_IMM   = 2;
parameter WBSRC_MEM         = 3;

module Argon (
    input wire i_clk,
    input wire i_halt,
    input wire i_reset,

    input logic [31:0] i_mem_data,
    output logic [31:0] o_mem_addr,
    output logic [2:0] o_mem_rd_mask,
    output logic [1:0] o_mem_wr_mask
);

    // system clock
    wire sys_clk;
    assign sys_clk = i_clk & ~i_halt;

    // Program counter
    logic [31:0] r_pc;
    logic [31:0] r_pc_next;
    wire [1:0] r_mux_pc_source; // 00: ALU result, 01: ALU out, 10: Jump target
    logic [31:0] w_pc_inc;
    assign w_pc_inc = 32'h4;
    logic r_pc_we;

    always_ff @(posedge i_clk or posedge i_reset) begin
        if (w_pc_we) r_pc <= w_pc_next;
    end

    // Instruction register
    logic [31:0] r_instruction;
    logic [5:0] w_opcode, w_funct6;
    logic [4:0] w_rs, w_rd, w_rt, w_shamt;
    logic [15:0] w_imm16;
    logic [25:0] w_jtarg;

    assign w_opcode = r_instruction[5:0];    // instruction opcode
    assign w_rs     = r_instruction[10:6];   // source register A
    assign w_rd     = r_instruction[15:11];  // dest. register
    assign w_rt     = r_instruction[20:16];  // source register B
    assign w_shamt  = r_instruction[25:21];  // shift amount
    assign w_funct6 = r_instruction[31:26]; // 6-bit function
    assign w_imm16  = r_instruction[31:16];  // 16-bit immediate
    assign w_sign_ext_imm = {16{w_imm16[15]}, w_imm16};
    assign w_branch_imm = {16{w_imm16[13]}, w_imm16 << 2}; // 32-bit offset immediate for branching
    assign w_lui_imm = {w_imm16, 16'b0}; // 32-bit immediate for loading into registers
    assign w_jtarg26  = r_instruction[31:6];   // 26-bit jump target
    logic [31:0] w_jump_target;
    assign w_jump_target = {r_pc[31:28], w_jtarg26, 2'b0}; // 32-bit jump address

    // Control unit FSM
    logic [2:0] r_stage;
    initial r_stage = STAGE_MEM;

    always_ff @(posedge i_clk) begin
        // defaults to prevent incorrect writes
        r_registers_write_en <= 0;
        r_pc_we <= 0;
        
        r_registers_selectA <= 0;
        r_registers_selectB <= 0;
        r_registers_selectW <= 0;
        r_alu_shamt <= 0;
        
        if (r_stage == STAGE_IF) begin
            r_stage <= STAGE_ID;

            r_instruction <= i_mem_data;
        
        end else if (r_stage == STAGE_ID) begin
            r_stage <= STAGE_EX;
            
            // handle bringup logic
            if (w_opcode == 0) begin
                r_registers_selectA = 0;
                r_registers_selectB = 0;
                r_registers_selectW = 0;
                r_alu_opcode = 0;
                r_alu_shamt = 0;
            end

            // handle R-type instruction decoding
            if (w_opcode == 1) begin
                if (w_funct6 < 16) begin // handle all R-type instrucctions before jmpr and jalr
                    r_registers_selectA <= w_rs;
                    r_registers_selectB <= w_rt;
                    r_registers_selectW <= w_rd;
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
                    r_alu_shamt <= w_shamt;

                    // select ALU sources
                    r_alu_srcA <= ALUSRCA_REG;
                    r_alu_srbB <= ALUSRCB_REG;
                end else begin
                    // handle jmpr and jalr

                end
            end

            // Handle I-type instruction opcodes
            if (w_opcode >= 2 && w_opcode <= 16) begin
                // Handle ALU w/ immediate opcodes
                if (w_opcode < 8) begin
                    r_alu_srcA <= ALUSRCA_REG;
                    r_registers_selectA <= w_rs;
                    r_alu_srbB <= ALUSRCB_IMM16;
                    r_registers_selectW <= w_rd;

                    case (w_opcode)
                        2: r_alu_opcode <= ALUOP_ADD;
                        3: r_alu_opcode <= ALUOP_SUB;
                        4: r_alu_opcode <= ALUOP_AND;
                        5: r_alu_opcode <= ALUOP_OR;
                        6: r_alu_opcode <= ALUOP_NOR;
                        7: r_alu_opcode <= ALUOP_XOR;
                    endcase
                end else if (w_opcode == 10) begin
                    // handle lui opcode
                end else if (w_opcode == 8 || w_opcode == 9) begin
                    // handle beq and bne opcodes
                end else begin
                    // handle memory access opcodes
                end
            end

            // implement hnadling for J-type instruction opcodes

        end else if (r_stage == STAGE_EX) begin
            r_stage <= STAGE_MEM;

            case (r_alu_srcA)
                ALUSRCA_PC: r_alu_wordA <= r_pc;
                ALUSRCA_REG: r_alu_wordA <= w_registers_portA;
            endcase
            case (r_alu_srcB)
                ALUSRCB_REG: r_alu_wordB <= w_registers_portB;
                ALUSRCB_IMM16: r_alu_wordB <= w_sign_ext_imm;
                ALUSRCB_PC_INC: r_alu_wordB <= w_pc_inc;
                ALUSRCB_BRANCH: r_alu_wordB <= w_branch_imm;
            endcase
        
        end else if (r_stage == STAGE_MEM) begin
            r_stage <= STAGE_WB;

            // Implement the waiting delay thingy
        
        end else if (r_stage == STAGE_WB) begin
            r_stage <= STAGE_IF;
            
            // Implement register writeback
        end

    end

    // RegisterFile instantiation
    logic r_registers_write_en;
    logic [4:0] r_registers_selectA, r_registers_selectB, r_registers_selectW;
    logic [31:0] w_registers_portA, w_registers_portB, w_registers_portW;
    
    RegisterFile registerfile_inst (
        .i_clk(sys_clk),
        .i_reset(i_reset),
        .i_write_en(w_registers_write_en),

        .i_selectA(w_registers_selectA),
        .i_selectB(w_registers_selectB),
        .i_selectW(w_registers_selectW),

        .o_portA(w_registers_portA),
        .o_portB(w_registers_portB),
        .i_portW(w_registers_portW),
        .i_write_mask(2'b00)
    );

    // ALU instantiation
    logic r_alu_srcA;
    logic [1:0] r_alu_srcB;
    logic [3:0] r_alu_opcode;
    logic [4:0] r_alu_shamt;
    logic [31:0] r_alu_wordA, r_alu_wordB, w_alu_result;
    logic w_alu_flag_equal, w_alu_flag_notequal;

    ALU alu_inst (
        .i_clk(sys_clk),
        .i_opcode(r_alu_opcode),
        .i_shamt(r_alu_shamt),

        .i_wordA(r_alu_wordA),
        .i_wordB(r_alu_wordB),
        .o_result(w_alu_result),

        .o_flag_equal(w_alu_flag_equal),
        .o_flag_notequal(w_alu_flag_notequal)
    );
    
endmodule