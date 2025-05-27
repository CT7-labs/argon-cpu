module Argon (
    input wire i_clk,
    input wire i_halt,
    input wire i_reset,
);

    // system clock
    wire sys_clk;
    assign sys_clk = i_clk & ~i_halt;

    // Program counter
    reg [31:0] r_pc;
    wire [31:0] w_pc_next;
    wire [1:0] r_mux_pc_source; // 00: ALU result, 01: ALU out, 10: Jump target
    wire [31:0] w_pc_inc;
    assign w_pc_inc = 32'h4;
    wire w_pc_we;

    always_ff @(posedge i_clk or posedge i_reset) begin
        if (w_pc_we) r_pc <= w_pc_next;
    end

    always_comb begin
        case (r_mux_pc_source)
            2'b00: w_pc_next = w_alu_result;
            2'b01: w_pc_next = r_alu_out;
            2'b10: w_pc_next = w_jump_target;
            default: 
        endcase
    end

    // Instruction register
    reg [31:0] r_instruction;
    wire [5:0] w_opcode, w_funct;
    wire [4:0] w_rs, w_rd, w_rt, w_shamt;
    wire [15:0] w_imm16;
    wire [25:0] w_jtarg;

    assign w_opcode = r_instruction[5:0];   // instruction opcode
    assign w_rs     = r_instruction[10:6];  // source register A
    assign w_rd     = r_instruction[15:11]; // dest. register
    assign w_rt     = r_instruction[20:16]; // source register B
    assign w_shamt  = r_instruction[25:21]; // shift amount
    assign w_funct  = r_instruction[31:26]; // 6-bit function
    assign w_imm16  = r_instruction[31:16]; // 16-bit immediate
    assign w_jtarg  = r_instruction[31:6];  // 26-bit jump target
    wire [31:0] w_jump_target;
    assign w_jump_target = {r_pc[31:28], (w_jtarg << 2)};

    // RegisterFile instantiation
    wire w_registers_write_en;
    wire [4:0] w_registers_selectA, w_registers_selectB, w_registers_selectW;
    wire [31:0] w_registers_portA, w_registers_portB, w_registers_portW;
    
    RegisterFile registerfile_inst (
        .i_clk(sys_clk),
        .i_reset(i_reset),
        .i_write_en(w_registers_write_en),

        .i_selectA(w_registers_selectA),
        .i_selectB(w_registers_selectB),
        .i_selectW(w_registers_selectW),

        .o_portA(w_registers_portA),
        .o_portB(w_registers_portB),
        .o_portW(w_registers_portW)
    );

    // ALU instantiation
    wire [3:0] w_alu_opcode;
    wire [4:0] w_alu_shamt;
    wire [31:0] w_alu_wordA, w_alu_wordB, w_alu_result;
    wire w_alu_flag_equal, w_alu_flag_notequal;
    reg [31:0] r_alu_out;

    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_alu_out <= 32'h0;
        end else begin
            r_alu_out <= w_alu_result;
        end
    end

    ALU alu_inst (
        .i_clk(sys_clk),
        .i_opcode(w_alu_opcode),
        .i_shamt(w_alu_shamt),

        .i_wordA(w_alu_wordA),
        .i_wordB(w_alu_wordB),
        .o_result(w_alu_result),

        .o_flag_equal(w_alu_flag_equal),
        .o_flag_notequal(w_alu_flag_notequal)
    );
    
endmodule