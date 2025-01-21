module ArgonALU (
    // master I/O
    input i_Clk,
    input i_Reset,
    input [15:0] i_bus,
    output [15:0] o_bus,
    output o_bus_valid,

    // control wires
    input i_latchA,
    input i_latchB,
    input i_latchF,
    input i_latchOp,
    input i_outputY,
    input i_outputF);
    
    // registers
    logic [15:0] rA, rB, rY, rFlags;
    logic [3:0] rOp;
    logic [16:0] rTemporary;
    logic [16:0] wResult;

    assign wResult = rTemporary;
    
    // operation constants
    parameter OP_ADD        = 4'h0;
    parameter OP_ADC        = 4'h1;
    parameter OP_SBC        = 4'h2;
    parameter OP_CMP        = 4'h3;
    parameter OP_INC        = 4'h4;
    parameter OP_DEC        = 4'h5;
    parameter OP_NAND       = 4'h6;
    parameter OP_AND        = 4'h7;
    parameter OP_OR         = 4'h8;
    parameter OP_NOR        = 4'h9;
    parameter OP_XOR        = 4'hA;
    parameter OP_LSH        = 4'hB;
    parameter OP_RSH        = 4'hC;
    parameter OP_RFU1        = 4'hD; // reserved for future use
    parameter OP_RFU2        = 4'hE; // reserved for future use
    parameter OP_RFU3        = 4'hF; // reserved for future use

    // flag constants
    parameter F_CARRY       = 0;
    parameter F_ZERO        = 1;
    parameter F_EQUAL       = 2;
    parameter F_GREATER     = 3;
    parameter F_LESS        = 4;
    parameter F_BORROW      = 5;
    parameter F_RFU1         = 6; // reserved for future use
    parameter F_RFU2         = 7; // reserved for future use

    // 17-bit zero-extended wires for operands
    logic [16:0] wA = {1'b0, rA};
    logic [16:0] wB = {1'b0, rB};

    // Combinational block for ALU operations
    always_comb begin
        case (rOp)
            OP_ADD: begin
                rTemporary = wA + wB;
            end

            OP_ADC: begin
                rTemporary = wA + wB;
                if (rFlags[F_CARRY]) rTemporary = rTemporary + 1;
            end

            OP_SBC: begin
                rTemporary = wA - wB;
                if (rFlags[F_CARRY]) rTemporary = rTemporary - 1;
            end

            OP_INC: begin
                rTemporary = wA + 1;
            end

            OP_DEC: begin
                rTemporary = wA - 1;
            end

            OP_NAND: begin
                rTemporary = {1'b0, ~(wA & wB)};
            end

            OP_AND: begin
                rTemporary = {1'b0, (wA & wB)};
            end

            OP_OR: begin
                rTemporary = {1'b0, (wA | wB)};
            end

            OP_NOR: begin
                rTemporary = {1'b0, ~(wA | wB)};
            end

            OP_XOR: begin
                rTemporary = {1'b0, (wA ^ wB)};
            end

            OP_LSH: begin
                rTemporary = wA << wB[3:0];
            end

            OP_RSH: begin
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
            rOp <= 0;
            rY <= 0;
        end

        // handle sequential ALU operations
        else begin
            // handle writing to the ALU
            if (i_latchA) begin
                rA <= i_bus;
            end
            else if (i_latchB) begin
                rB <= i_bus;
            end
            else if (i_latchF) begin
                rFlags <= i_bus[15:0];
            end
            else if (i_latchOp) begin
                rOp <= i_bus[3:0];
            end

            // update registers
            else begin
                case (rOp)
                    OP_ADD, OP_ADC, OP_SBC, OP_INC,
                    OP_DEC, OP_NAND, OP_AND, OP_OR,
                    OP_NOR, OP_XOR, OP_LSH, OP_RSH: begin
                        rY <= rTemporary[15:0];
                        rFlags[F_CARRY] <= w_carry;
                        rFlags[F_ZERO] <= w_zero;
                    end

                    OP_CMP: begin
                        rFlags[F_ZERO] <= w_zero;
                        rFlags[F_EQUAL] <= w_equal;
                        rFlags[F_GREATER] <= w_greater;
                        rFlags[F_LESS] <= w_less;
                    end

                    default: begin
                        // Reserved opcodes do nothing
                    end
                endcase
            end
        end

    end

    // handle reading from the ALU
    assign o_bus = i_outputY ? rY :
                    i_outputF ? rFlags :
                    16'h0000;

    assign o_bus_valid = i_outputY || i_outputF;
endmodule