import constants_pkg::*;
import stack_pkg::*;

module ArgonStack
(
    input i_Clk,
    input i_Reset,
    bus_if bus_if
);

    logic [7:0] sp;
    word_t o_stack;
    logic push, pop, valid_out;

    assign bus_if.o_data = (bus_if.command == COM_READ_PTR) ? {8'b0, sp} : o_stack;
    assign bus_if.o_valid = (valid_out & pop) | (bus_if.command == COM_READ_PTR);

    always_comb begin
        // defaults
        push = 1'b0;
        pop = 1'b0;

        case (bus_if.command)
            COM_PUSH: push = 1'b1;
            COM_POP: pop = 1'b1;
            default: begin
                push = 1'b0;
                pop = 1'b0;
            end
        endcase
    end

    // SP control logic
    always_ff @(posedge i_Clk or posedge i_Reset) begin
        if (i_Reset) begin
            sp <= 8'b0;   
        end
        else begin
            case (bus_if.command)
                COM_LOAD_PTR: sp <= bus_if.i_data[7:0];  // Write to SP
                COM_PUSH: sp <= sp + 1;               // Increment on push
                COM_POP: sp <= sp - 1;               // Decrement on pop
                default: sp <= sp;
            endcase
        end
    end

    Mem256x16 stackmem (
        .clk(i_Clk),
        .rd_en(pop),
        .wr_en(push),
        .rd_addr(sp - 8'd1),
        .wr_addr(sp),
        .data_in(bus_if.i_data),
        .data_out(o_stack),
        .valid_out(valid_out)
    );

endmodule