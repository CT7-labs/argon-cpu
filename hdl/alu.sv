import constants_pkg::*;
import alu_pkg::*;

module ArgonALU (
    // Interface signals
    input i_Clk,
    input i_Reset,
    bus_if bus_if);
    
    // registers
    word_t rA, rB;     // data registers
    word_t rFlags;          // Flags register
    logic [3:0] rOp;        // ALU opcode

    // Computational wires
    logic [WORDSIZE:0] wA = {1'b0, rA}; // 17-bit zero-extended A
    logic [WORDSIZE:0] wB = {1'b0, rB}; // 17-bit zero-extended B
    logic [WORDSIZE:0] wResult;         // 17-bit extended result

    // decoding internal control signals from command input

    logic i_latchA, i_latchB, i_latchF, i_latchOp, i_outputY, i_outputF;
    
    always_comb begin
        i_latchA = (bus_if.command == com_latchA) ? 1'b1 : 1'b0;
        i_latchB = (bus_if.command == com_latchB) ? 1'b1 : 1'b0;
        i_latchF = (bus_if.command == com_latchF) ? 1'b1 : 1'b0;
        i_latchOp = (bus_if.command == com_latchOp) ? 1'b1 : 1'b0;
        i_outputY = (bus_if.command == com_outputY) ? 1'b1 : 1'b0;
        i_outputF = (bus_if.command == com_outputF) ? 1'b1 : 1'b0; 
    end

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
    struct packed {
        logic carry;
        logic zero;
        logic equal;
        logic greater;
        logic less;
        logic borrow;
    } w_flags;

    assign w_flags = '{
        carry:     wResult[16],
        zero:      (wResult[15:0] == 0),
        equal:     (rA == rB),
        greater:   (rA > rB),
        less:      (rA < rB),
        borrow:    (wResult[16])
    };

    always_ff @(posedge i_Clk or posedge i_Reset) begin
        // handle reset
        if (i_Reset) begin
            rA <= 0;
            rB <= 0;
            rFlags <= 0;
            rOp <= 0;
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
        end

    end

    // handle reading from the ALU
    always_comb begin
        if (i_outputY)
            bus_if.o_data = wResult[15:0];
        else if (i_outputF)
            bus_if.o_data = w_flags;
        else
            bus_if.o_data = 16'h0000;
    end

    /*
    the above always_comb block could be implemented with this assign statement:

    assign bus_if.o_data = i_outputY ? wResult :
                            i_outputF ? rFlags :
                            16'h0000;
    */

    assign bus_if.o_valid = i_outputY | i_outputF;

endmodule
