import argon_pkg::*;

module SimTop (
    input i_Clk,
    input i_Reset,

    // for testing simulating with verilator
    output word_t i_debug,
    output i_debug_valid,
    input word_t o_debug,
    input o_debug_valid,

    // control unit will take over these ports
    input [3:0] write_id,
    input [3:0] read_id,

    // control wires (ALU)
    input i_latchA,
    input i_latchB,
    input i_latchF,
    input i_latchOp,
    input i_outputY,
    input i_outputF,

    // control wires (RegFile)
    input i_selectLatch,
    input i_outputA,
    input i_outputB,
    input i_latchC);

    // bus interfaces
    master_bus_if master_bus();
    assign master_bus.read_id = read_id;
    assign master_bus.write_id = write_id;

    bus_if alu_bus();
    bus_if regfile_bus();
    bus_if debug_bus();
    assign i_debug = debug_bus.i_data;
    assign i_debug_valid = debug_bus.i_valid;
    assign debug_bus.o_data = o_debug;
    assign debug_bus.o_valid = o_debug_valid;

    always_comb begin
        // define defaults (prevent latches)
        master_bus.o_data = 0;
        master_bus.o_valid = 0;

        // handle reading from units on the bus
        case (read_id)
            ID_ALU: begin
                if (alu_bus.o_valid) begin
                    master_bus.o_data = alu_bus.o_data;
                    master_bus.o_valid = alu_bus.o_valid;
                end 
            end

            ID_REGFILE: begin
                if (regfile_bus.o_valid) begin
                    master_bus.o_data = regfile_bus.o_data;
                    master_bus.o_valid = regfile_bus.o_valid;
                end
            end

            ID_DEBUG: begin
                if (debug_bus.o_valid) begin
                    master_bus.o_data = debug_bus.o_data;
                    master_bus.o_valid = debug_bus.o_valid;
                end
            end
        endcase

        // handle writing to units on the bus
        case (write_id)
            ID_ALU: begin
                alu_bus.i_data = master_bus.o_data;
                alu_bus.i_valid = master_bus.o_valid;
            end

            ID_REGFILE: begin
                regfile_bus.i_data = master_bus.o_data;
                regfile_bus.i_valid = master_bus.o_valid;
            end

            ID_DEBUG: begin
                debug_bus.i_data = master_bus.o_data;
                debug_bus.i_valid = master_bus.o_valid;
            end

            default: begin
                master_bus.i_data = master_bus.o_data;
                master_bus.i_valid = 0;
            end
        endcase
    end

    // device instances

    // ALU
    ArgonALU inst_ArgonALU (
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .bus_if(alu_bus),
        .i_latchA(i_latchA),
        .i_latchB(i_latchB),
        .i_latchF(i_latchF),
        .i_latchOp(i_latchOp),
        .i_outputY(i_outputY),
        .i_outputF(i_outputF));

    ArgonRegFile inst_ArgonRegFile (
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .bus_if(regfile_bus),
        .i_selectLatch(i_selectLatch),
        .i_outputA(i_outputA),
        .i_outputB(i_outputB),
        .i_latchC(i_latchC));
endmodule