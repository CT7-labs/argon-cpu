import argon_pkg::*;

module ArgonALU (
    // master I/O
    input i_Clk,
    input i_Reset,
    bus_if bus,

    // control wires (ALU)
    input i_latchA,
    input i_latchB,
    input i_latchF,
    input i_latchOp,
    input i_outputY,
    input i_outputF);
    
    // registers
    word_t rA, rB, rY, rFlags;
    logic [3:0] rALU;
    logic [WORDSIZE:0] rTemporary;
    logic [WORDSIZE:0] wResult;

    assign wResult = rTemporary;

    // 17-bit zero-extended wires for ALUerands
    logic [16:0] wA = {1'b0, rA};
    logic [16:0] wB = {1'b0, rB};

    // Combinational block for ALU ALUerations
    always_comb begin
        case (rALU)
            ALU_ADD: begin
                rTemporary = wA + wB;
            end

            ALU_ADC: begin
                rTemporary = wA + wB;
                if (rFlags[F_CARRY]) rTemporary = rTemporary + 1;
            end

            ALU_SBC: begin
                rTemporary = wA - wB;
                if (rFlags[F_CARRY]) rTemporary = rTemporary - 1;
            end

            ALU_INC: begin
                rTemporary = wA + 1;
            end

            ALU_DEC: begin
                rTemporary = wA - 1;
            end

            ALU_NAND: begin
                rTemporary = {1'b0, ~(wA & wB)};
            end

            ALU_AND: begin
                rTemporary = {1'b0, (wA & wB)};
            end

            ALU_OR: begin
                rTemporary = {1'b0, (wA | wB)};
            end

            ALU_NOR: begin
                rTemporary = {1'b0, ~(wA | wB)};
            end

            ALU_XOR: begin
                rTemporary = {1'b0, (wA ^ wB)};
            end

            ALU_LSH: begin
                rTemporary = wA << wB[3:0];
            end

            ALU_RSH: begin
                rTemporary = wA >> wB[3:0];
            end

            default: begin
                rTemporary = 0; // defualt case does nothing
            end
        endcase
    end

    // combinatational block for flags
    logic w_carry = rTemporary[16];
    logic w_zero = (rTemporary[15:0] == 0);
    logic w_equal = (rA == rB);
    logic w_greater = (rA > rB);
    logic w_less = (rA < rB);
    logic w_borrow = (rTemporary[16]);

    always_ff @(posedge i_Clk or posedge i_Reset) begin
        // handle reset
        if (i_Reset) begin
            rA <= 0;
            rB <= 0;
            rFlags <= 0;
            rALU <= 0;
            rY <= 0;
        end

        // handle sequential ALU ALUerations
        else begin
            // handle writing to the ALU
            if (i_latchA) begin
                rA <= bus.i_data;
            end
            else if (i_latchB) begin
                rB <= bus.i_data;
            end
            else if (i_latchF) begin
                rFlags <= bus.i_data;
            end
            else if (i_latchOp) begin
                rALU <= bus.i_data[3:0];
            end

            // update registers
            else begin
                case (rALU)
                    ALU_ADD, ALU_ADC, ALU_SBC, ALU_INC,
                    ALU_DEC, ALU_NAND, ALU_AND, ALU_OR,
                    ALU_NOR, ALU_XOR, ALU_LSH, ALU_RSH: begin
                        rY <= rTemporary[15:0];
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
    assign bus.o_data = i_outputY ? rY :
                    i_outputF ? rFlags :
                    16'h0000;

    assign bus.valid = i_outputY | i_outputF;
endmodule
