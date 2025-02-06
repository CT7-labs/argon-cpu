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
import regfile_alu_shared_pkg::*;

module ArgonRegFile (
    input i_Clk,
    input i_Reset,
    bus_if bus_if,

    // communication between RegFile and ALU
    output word_t o_reg_a,
    output word_t o_reg_b,
    output word_t o_reg_flags,
    input word_t i_write_data,
    input write_sel_t i_write_select); // set to 0 to disable writing

    // define registers
    word_t registers [1:REGISTERS-1];
    reg_addr_t selA, selB, selC;

    // assign outputs to ALU
    assign o_reg_a     = registers[selA];
    assign o_reg_b     = registers[selB];
    assign o_reg_flags = registers[R_F];

    // handle outputs to Argon bus
    always_comb begin
        case (bus_if.command)
            COM_READA: begin
                bus_if.o_valid = 1;
                bus_if.o_data = (selA != 0) ? registers[selA] : '0;
            end

            COM_READB: begin
                bus_if.o_valid = 1;
                bus_if.o_data = (selB != 0) ? registers[selB] : '0;
            end

            COM_READF: begin
                bus_if.o_valid = 1;
                bus_if.o_data = registers[R_F];
            end

            default: begin
                bus_if.o_valid = 0;
                bus_if.o_data = '0;
            end
        endcase
    end

    always_ff @(posedge i_Clk or posedge i_Reset) begin
        if (i_Reset) begin
            selA <= '0;
            selB <= '0;
            selC <= '0;

            for (int i = 1; i < REGISTERS; i++) begin
                registers[i] <= 0;
            end
        end

        else begin
            // handle writes from ALU to register file
            // if control unit OKs it
            if (bus_if.command == COM_ALU_WE) begin
                case (i_write_select)
                    WSEL_REGC: registers[selC] <= i_write_data;
                    WSEL_REGF: registers[R_F] <= i_write_data;
                    default: begin
                        // nothing
                    end
                endcase
            end
            

            // write to registers[selC] with data from bus
            if (bus_if.command == COM_LATCHC && selC != 0) begin
                if (bus_if.i_valid) registers[selC] <= bus_if.i_data;
                else bus_if.error <= ERROR_INVALID_INPUT; 
            end

            // update selected registers with data from bus
            if (bus_if.command == COM_LATCHSEL) begin
                if (bus_if.i_valid) begin
                    selA <= bus_if.i_data[INDEX_WIDTH-1:0];
                    selB <= bus_if.i_data[2*INDEX_WIDTH-1:INDEX_WIDTH];
                    selC <= bus_if.i_data[3*INDEX_WIDTH-1:INDEX_WIDTH*2];
                end
            end
        end
    end

endmodule