import argon_pkg::*;

module ArgonALU (
    // master I/O
    input i_Clk,
    input i_Reset,
    bus_if bus_if,

    // control wires (ALU)
    input i_latchA,
    input i_latchB,
    input i_latchF,
    input i_latchOp,
    input i_outputY,
    input i_outputF);
    
    // registers
    word_t rA, rB, rY, rFlags;
    logic [3:0] rOp;
    logic [WORDSIZE:0] wResult;

    // 17-bit zero-extended wires for ALUerands
    logic [16:0] wA = {1'b0, rA};
    logic [16:0] wB = {1'b0, rB};

    // Combinational block for ALU ALUerations
    always_comb begin
        case (rOp)
            ALU_ADD: begin
                wResult = wA + wB;
            end

            ALU_ADC: begin
                wResult = wA + wB;
                if (rFlags[F_CARRY])
                    wResult = wResult + 1;
            end

            ALU_SBC: begin
                wResult = wA - wB;
                if (rFlags[F_CARRY])
                    wResult = wResult - 1;
            end

            ALU_INC: begin
                wResult = wA + 1;
            end

            ALU_DEC: begin
                wResult = wA - 1;
            end

            ALU_NAND: begin
                wResult = {1'b0, ~(wA & wB)};
            end

            ALU_AND: begin
                wResult = {1'b0, (wA & wB)};
            end

            ALU_OR: begin
                wResult = {1'b0, (wA | wB)};
            end

            ALU_NOR: begin
                wResult = {1'b0, ~(wA | wB)};
            end

            ALU_XOR: begin
                wResult = {1'b0, (wA ^ wB)};
            end

            ALU_LSH: begin
                wResult = wA << wB[3:0];
            end

            ALU_RSH: begin
                wResult = wA >> wB[3:0];
            end

            default: begin
                wResult = 0; // defualt case returns 0
            end
        endcase
    end

    // combinatational block for flags
    logic w_carry = wResult[16];
    logic w_zero = (wResult[15:0] == 0);
    logic w_equal = (rA == rB);
    logic w_greater = (rA > rB);
    logic w_less = (rA < rB);
    logic w_borrow = (wResult[16]);

    always_ff @(posedge i_Clk or posedge i_Reset) begin
        // handle reset
        if (i_Reset) begin
            rA <= 0;
            rB <= 0;
            rFlags <= 0;
            rOp <= 0;
            rY <= 0;
        end

        // handle sequential ALU ALUerations
        else begin
            // handle writing to the ALU
            if (bus_if.i_valid) begin
                if (i_latchA) begin
                    rA <= bus_if.i_data;
                end

                else if (i_latchB) begin
                    rB <= bus_if.i_data;
                end

                else if (i_latchF) begin
                    rFlags <= bus_if.i_data;
                end

                else if (i_latchOp) begin
                    rOp <= bus_if.i_data[3:0];
                end 
            end

            // update registers
            else begin
                case (rOp)
                    ALU_ADD, ALU_ADC, ALU_SBC, ALU_INC,
                    ALU_DEC, ALU_NAND, ALU_AND, ALU_OR,
                    ALU_NOR, ALU_XOR, ALU_LSH, ALU_RSH: begin
                        rY <= wResult[15:0];
                        rFlags[F_CARRY] <= w_carry;
                        rFlags[F_ZERO] <= w_zero;
                    end

                    ALU_CMP: begin
                        rFlags[F_ZERO] <= w_zero;
                        rFlags[F_EQUAL] <= w_equal;
                        rFlags[F_GREATER] <= w_greater;
                        rFlags[F_LESS] <= w_less;
                    end

                    default: begin
                        // Reserved ALUcodes do nothing
                    end
                endcase
            end
        end

    end

    // handle reading from the ALU
    always_comb begin
        if (i_outputY)
            bus_if.o_data = wResult[15:0];
        else if (i_outputF)
            bus_if.o_data = rFlags;
        else
            bus_if.o_data = 16'h0000;
    end

    /*
    the above always_comb block could be implemented with this assign statement:

    assign bus_if.o_data = i_outputY ? rY :
                            i_outputF ? rFlags :
                            16'h0000;
    */

    assign bus_if.o_valid = i_outputY | i_outputF;

endmodule
