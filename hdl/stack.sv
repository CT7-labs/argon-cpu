import constants_pkg::*;
import stack_pkg::*;

module ArgonStack
(
    input i_Clk,
    input i_Reset,
    bus_if bus_if,
    
    // stack pointer from RegFile
    input logic [7:0] i_reg_sp);

    word_t o_stack;
    logic push, pop, valid_out;

    assign bus_if.o_valid = (valid_out & pop) | (bus_if.command == COM_READ_PTR);
    assign bus_if.o_data = o_stack;

    always_comb begin
        case (bus_if.command)
            COM_PUSH: push = 1'b1;
            COM_POP: pop = 1'b1;
            default: begin
                push = 1'b0;
                pop = 1'b0;
            end
        endcase
    end

    logic [7:0] rd_addr, wr_addr;

    assign rd_addr = i_reg_sp + 1;
    assign wr_addr = i_reg_sp;

    Mem256x16 stackmem (
        .clk(i_Clk),
        .rd_en(1),
        .wr_en(push),
        .rd_addr(rd_addr),
        .wr_addr(wr_addr),
        .data_in(bus_if.i_data),
        .data_out(o_stack),
        .valid_out(valid_out)
    );

endmodule