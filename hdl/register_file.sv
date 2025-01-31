/*

+-------------------+
|   Register File   |
+-------------------+

r0  -   Zero register
r1  -   General-purpose register
r2  -   General-purpose register
r3  -   General-purpose register
r4  -   General-purpose register
RV  -   General-purpose register / return value
SP  -   Stack pointer
F   -   Flags register

The lower 8 bits of the flags register mirror the ALU's internal flags register

*/

import constants_pkg::*;
import regfile_pkg::*;

module ArgonRegFile (
    input i_Clk,
    input i_Reset,
    bus_if bus_if);

    // define register file and index registers
    word_t [15:0] regfile [1:REGISTERS-1]; // saves LEs by not defining a zero register
    logic [INDEX_WIDTH-1:0] indexA, indexB, indexC;

    always_ff @(posedge i_Clk or posedge i_Reset) begin
        if (i_Reset) begin
            for (int i = 1; i < REGISTERS; i++) begin
                regfile[i] <= '0;
            end

            indexA <= '0;
            indexB <= '0;
            indexC <= '0;
        end

        // write to regfile
        else if (bus_if.i_valid) begin
            case (bus_if.command)

                // write to regC
                COM_LATCHC:
                    if (indexC != 0)
                        regfile[indexC] <= bus_if.i_data;
                
                // latch new indices for regA, B, and C
                COM_LATCHSEL: begin
                    indexA <= bus_if.i_data[INDEX_WIDTH-1:0];
                    indexB <= bus_if.i_data[2*INDEX_WIDTH-1:INDEX_WIDTH];
                    indexC <= bus_if.i_data[3*INDEX_WIDTH-1:2*INDEX_WIDTH];
                end

                COM_LATCHRV:
                    regfile[RV] <= bus_if.i_data;

                COM_LATCHSP:
                    regfile[SP] <= bus_if.i_data;
                
                COM_LATCHF:
                    // only write to the lower 8 bits
                    regfile[F][7:0] <= bus_if.i_data[7:0];

                default: begin
                    // nothing happens
                end
            endcase
        end
    end

    // read from regfile
    always_comb begin
        case (bus_if.command)
            COM_READA: begin
                bus_if.o_valid = 1;
                bus_if.o_data = (indexA != 0) ? regfile[indexA] : '0;
            end

            COM_READB: begin
                bus_if.o_valid = 1;
                bus_if.o_data = (indexB != 0) ? regfile[indexB] : '0;
            end

            COM_READRV: begin
                bus_if.o_valid = 1;
                bus_if.o_data = regfile[RV];
            end

            COM_READSP: begin
                bus_if.o_valid = 1;
                bus_if.o_data = regfile[SP];
            end

            COM_READF: begin
                bus_if.o_valid = 1;
                bus_if.o_data = regfile[F];
            end

            default: begin
                bus_if.o_valid = 0;
                bus_if.o_data = '0;
            end
        endcase
    end

endmodule
