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

1. Load rA
2. Load rB
3. Load rOp
4. Load rF (depending on operation)
5. Latch internal result into rY and rF
6. Output result
7. Output flags

*/

import constants_pkg::*;
import alu_pkg::*;

module ArgonALU (
    // Interface signals
    input i_Clk,
    input i_Reset,
    bus_if bus_if);
    
    // registers
    word_t rA, rB, rY;
    logic [7:0] rF;
    logic [3:0] rOp;


    // handle clocked logic
    always_ff @(posedge i_Clk or posedge i_Reset) begin

        // reset logic
        if (i_Reset) begin
            rA <= '0;
            rB <= '0;
            rF <= '0;
            rY <= '0;
            rOp <= '0;
        end

        // command interpretation
        else if (bus_if.command == COM_COMPUTE) begin
            rY <= extended_result[WORDSIZE-1:0];
            rF <= result_flags;
        end

        else if (bus_if.i_valid) begin
            case (bus_if.command)
                COM_LATCHA:
                    rA <= bus_if.i_data;
                
                COM_LATCHB:
                    rB <= bus_if.i_data;
                
                COM_LATCHF:
                    rF <= bus_if.i_data;
                
                COM_LATCHOP:
                    rOp <= bus_if.i_data[3:0];
                
                default: begin
                    // do nothing; don't write to internal registers
                end
            endcase
        end
    end

    always_comb begin
        case (bus_if.command)
            COM_OUTPUTY: begin
                bus_if.o_data = rY; 
                bus_if.o_valid = 1;
            end

            COM_OUTPUTF: begin
                bus_if.o_data = {{{WORDSIZE-8}{1'b0}}, rF};
                bus_if.o_valid = 1;
            end

            default: begin
                bus_if.o_data = '0;
                bus_if.o_valid = 0;
            end
        endcase
    end

    // compute
    logic [WORDSIZE:0] extended_rA = {1'b0, rA};
    logic [WORDSIZE:0] extended_rB = {1'b0, rB};
    logic [WORDSIZE:0] extended_result;
    word_t result_flags;

    always_comb begin
        result_flags = '0;

        case (rOp)
            ALU_ADD: begin
                extended_result = extended_rA + extended_rB;

                result_flags[F_CARRY] = extended_result[WORDSIZE];
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_ADC: begin
                extended_result = extended_rA + extended_rB + rF[F_CARRY];

                result_flags[F_CARRY] = extended_result[WORDSIZE];
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_SBB: begin
                extended_result = extended_rA - extended_rB - rF[F_BORROW];

                result_flags[F_BORROW] = extended_rA < extended_rB;
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
            end

            ALU_CMP: begin
                extended_result = {1'b0, rY}; // don't overwrite the Y register

                result_flags[F_EQUAL] = extended_rA == extended_rB;
                result_flags[F_GREATER] = extended_rA > extended_rB;
                result_flags[F_LESS] = extended_rA < extended_rB;
                result_flags[F_ZERO] = (extended_result[WORDSIZE-1:0] == '0);
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
            end

            ALU_NOR: begin
                extended_result = ~(extended_rA | extended_rB);
            end

            ALU_XOR: begin
                extended_result = extended_rA ^ extended_rB;
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
