/*

+---------------+
|   Argon ALU   |
+---------------+

- 16 opcodes
- 16-bit unsigned arithmetic
- 8-bit flags register (loaded with the lower 8-bits)
- Single bus operation

+-----------+
|   Usage   |
+-----------+

0. Register file selects the correct A, B, and C registers
1. Load rOp from bus
2. Latch result into C register
3. Latch result flags into F register

+------------------------+
|   Intended functions   |
+------------------------+

ADD
Y = A + B

flags updated: Carry, Zero

ADC
Y = A + B + CF

flags updated: Carry, Zero

SUB
Y = A - B

flags updated: borrow, zero

SBB
Y = A - B - BF

flags updated: Borrow, Zero

CMP
Y = Y

greater: a > b
less: a < b
equal: a == b

INC
Y = A + 1

DEC
Y = A - 1

NAND
Y = ~(A & B)

AND
Y = A & B

OR
Y = A | B

NOR
Y = ~(A | B)

XOR
Y = A ^ B

LSH
Y = A << B

RSH
Y = A >> B

ROL
Y = (A << B) | (A >> WORDSIZE - B)

ROR
Y = (A << WORDSIZE - B) | (A >> B)

*/

import constants_pkg::*;
import alu_pkg::*;
import regfile_alu_shared_pkg::*;

module ArgonALU (
    // Interface signals
    input i_Clk,
    input i_Reset,
    bus_if bus_if,
    
    input word_t i_reg_a,
    input word_t i_reg_b,
    input word_t i_reg_flags,
    output word_t o_write_data,
    output write_sel_t o_write_select);

    // registers / wires
    logic [WORDSIZE:0] extended_rA = {1'b0, i_reg_a};
    logic [WORDSIZE:0] extended_rB = {1'b0, i_reg_b};
    logic [WORDSIZE:0] extended_result;
    logic [7:0] result_flags;
    logic [3:0] rOp;

    // handle clocked logic
    always_ff @(posedge i_Clk or posedge i_Reset) begin

        // reset logic
        if (i_Reset) begin
            rOp <= '0;
        end

        // command interpretation
        else if (bus_if.i_valid) begin
            if (bus_if.command == COM_LATCHOP) rOp <= bus_if.i_data[3:0];
        end
    end

    always_comb begin
        // handle writing to RegFile
        if (bus_if.command == COM_WRITEC) begin
            o_write_select = WSEL_REGC;
            o_write_data = extended_result[WORDSIZE-1:0];
        end
        else if (bus_if.command == COM_WRITEF) begin
            o_write_select = WSEL_REGF;
            o_write_data = {i_reg_flags[WORDSIZE-1:8], result_flags[7:0]};
        end
        else o_write_select = '0;

        // handle computing

        result_flags = '0;

        case (rOp)
            ALU_ADD: begin
                extended_result = extended_rA + extended_rB;

                result_flags[F_CARRY] = extended_result[WORDSIZE];
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_ADC: begin
                extended_result = extended_rA + extended_rB + i_reg_flags[F_CARRY];

                result_flags[F_CARRY] = extended_result[WORDSIZE];
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_SUB: begin
                extended_result = extended_rA - extended_rB;;

                result_flags[F_BORROW] = extended_rA < extended_rB;
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_SBB: begin
                extended_result = extended_rA - extended_rB - i_reg_flags[F_BORROW];

                result_flags[F_BORROW] = extended_rA < extended_rB;
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_CMP: begin
                extended_result = '0;

                result_flags[F_EQUAL] = extended_rA == extended_rB;
                result_flags[F_GREATER] = extended_rA > extended_rB;
                result_flags[F_LESS] = extended_rA < extended_rB;
            end

            ALU_INC: begin
                extended_result = extended_rA + 1;

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_DEC: begin
                extended_result = extended_rA - 1;

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_NAND: begin
                extended_result = ~(extended_rA & extended_rB);

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_AND: begin
                extended_result = extended_rA & extended_rB;

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_OR: begin
                extended_result = extended_rA | extended_rB;

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_NOR: begin
                extended_result = ~(extended_rA | extended_rB);

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_XOR: begin
                extended_result = extended_rA ^ extended_rB;

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_LSH: begin
                extended_result = extended_rA << extended_rB[3:0];

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_RSH: begin
                extended_result = extended_rA >> extended_rB[3:0];

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_ROL: begin
                extended_result = extended_rA << extended_rB[3:0] | extended_rA >> (WORDSIZE - extended_rB[3:0]);

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_ROR: begin
                extended_result = extended_rA >> extended_rB[3:0] | extended_rA << (WORDSIZE - extended_rB[3:0]);

                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            default:begin
                extended_result = '0;
                result_flags[F_ERROR] = 1;
            end
        endcase
    end

endmodule
