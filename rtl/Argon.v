module Argon (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // Memory interface
    input wire [15:0] i_memory_data,
    output reg [15:0] o_memory_data,
    output reg [15:0] o_memory_address,
    output reg o_memory_re,
    output reg o_memory_we
);
    // Clock wire
    wire sys_clk;
    assign sys_clk = (i_clk & ~i_halt);

    // Control unit
    reg [15:0] r_program_counter;
    localparam PC_INCREMENT = 16'h0004;
    reg [1:0] r_instruction_stage;
    reg r_instruction_is_executing;

    /*
    IFINIT  - Initializes instruction fetch
    IFW     - Waits on address to latch
    IF1     - Fetches first instruction half
    IF2     - Fetches second instruction halftransaction with memory unit

    ID      - Sets multiplexer logic
    EX      - ALU performs computation
    MEM    - Memory delay
    WB      - Register writeback
    */
    
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

    // === Muxing ===
    reg r_mux_registers_writeback;    // 0: ALU result, 1: imm16
    reg r_mux_alu_selectB;            // 0: Registers portB, 1: imm16

    // === Combinational control ===
    // ALU
    assign w_alu_wordB = (r_mux_alu_selectB) ? w_registers_portB : w_instruction_imm16;
    assign w_registers_portW = (r_mux_registers_writeback) ? w_alu_result : w_instruction_imm16;
    
    // === Module Instantiation ===
    // ALU
    wire [15:0] w_alu_wordB, w_alu_result; // w_alu_wordA isn't needed because it's fed directly by w_registers_portA
    wire [3:0] w_alu_opcode;
    assign w_alu_opcode = w_instruction_funct6[3:0];
    wire w_alu_flag_zero, w_alu_flag_sign, w_alu_flag_overflow, w_alu_flag_carry;

    ALU inst_alu (
        .i_clk(sys_clk),
        .i_opcode(w_alu_opcode),

        .i_wordA(w_registers_portA), // no muxing needed
        .i_wordB(w_alu_wordB),
        .o_result(w_alu_result),

        .o_flag_zero(w_alu_flag_zero),
        .o_flag_sign(w_alu_flag_sign),
        .o_flag_overflow(w_alu_flag_overflow),
        .o_flag_carry(w_alu_flag_carry)
    );

    // Register File
    wire [15:0] w_registers_portA, w_registers_portB; // data ports
    wire [3:0] w_registers_selectA, w_registers_selectB, w_registers_selectW; // select ports
    reg r_registers_write_en; // Write-enable flag

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
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            // Mux reset
            r_mux_registers_writeback <= 0;
            r_mux_alu_selectB <= 0;
            r_registers_write_en <= 0;
            
            // Instruction execution reset
            r_instruction <= 0;
            r_instruction_stage <= STEP_IF1;
            r_program_counter <= 0;
            r_instruction_is_executing <= 0;
        
        end else begin
            if (~r_instruction_is_executing) begin
                r_registers_write_en <= 0;
                case (r_instruction_stage)
                    // IFINIT
                    2'b00: begin
                        o_memory_address <= r_program_counter;
                        o_memory_re <= 1;
                        o_memory_we <= 0;
                        
                        r_instruction_stage <= r_instruction_stage + 1;
                    end
                    2'b01: begin
                        o_memory_address <= r_program_counter + 2;
                        o_memory_re <= 1;
                        o_memory_we <= 0;

                        r_instruction[0:15] <= i_memory_data;

                        r_instruction_stage <= r_instruction_stage + 1;
                    end
                    2'b10: begin
                        o_memory_address <= 0;
                        r_program_counter <= r_program_counter + PC_INCREMENT;
                        o_memory_re <= 0;
                        o_memory_we <= 0;

                        r_instruction[31:16] <= i_memory_data;

                        r_instruction_stage <= 0;
                        r_instruction_is_executing <= 1
                    end
                endcase
            end

            if (r_instruction_is_executing) begin
                case (r_instruction_stage)
                    // Instruction decode
                    2'b00: begin
                        // Register/register opcodes
                        if (w_instruction_opcode < 8) begin
                            r_mux_alu_selectB <= 0; // source ALU's wordB from Registers
                            r_mux_registers_writeback <= 0; // source Registers' writeback from ALU
                        end
                        // Immediate opcodes
                        // Branch opcodes
                        // Jump opcodes
                        // 
                        r_instruction_stage <= r_instruction_stage + 1;
                    end

                    // Instruction execute
                    2'b01: begin
                        // Register/register opcodes
                        if (w_instruction_opcode < 8) begin
                            // nothing
                            r_instruction_stage <= 2'b11; // skip memory access
                        end
                    end

                    // Memory access
                    2'b10: begin
                        
                    end

                    // Register writeback
                    2'b11: begin
                        // Register/register opcodes
                        if (w_instruction_opcode < 8) begin
                            r_registers_write_en <= 1;
                        end

                        r_instruction_stage <= 2'b00;
                        r_instruction_is_executing <= 0;
                    end
                endcase
            end
        end
    end
    
endmodule