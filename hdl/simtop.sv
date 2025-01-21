import argon_pkg::*;

module SimTop (
    input i_Clk,
    input i_Reset,
    input [15:0] i_bus,
    output logic [15:0] o_bus,

    // for testing/simulating in Verilator
    input i_latchA,
    input i_latchB,
    input i_latchF,
    input i_latchOp,
    input i_outputY,
    input i_outputF,
    output o_bus_valid,

    // control wires (RegFile)
    input i_selectLatch,
    input i_outputA,
    input i_outputB,
    input i_latchC);

    // bus interfaces & muxing
    bus_if alu_bus();
    bus_if regfile_bus();

    assign alu_bus.i_data = i_bus;
    assign regfile_bus.i_data = i_bus;

    always_comb begin
        if (alu_bus.valid)
            o_bus = alu_bus.o_data;
        else if (regfile_bus.valid)
            o_bus = regfile_bus.o_data;
    end

    assign o_bus_valid = alu_bus.valid | regfile_bus.valid;

    // instances

    ArgonALU inst_ArgonALU (
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .bus(alu_bus),
        .i_latchA(i_latchA),
        .i_latchB(i_latchB),
        .i_latchF(i_latchF),
        .i_latchOp(i_latchOp),
        .i_outputY(i_outputY),
        .i_outputF(i_outputF));
    
    ArgonRegFile inst_ArgonRegFile (
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .bus(regfile_bus),
        .i_selectLatch(i_selectLatch),
        .i_outputA(i_outputA),
        .i_outputB(i_outputB),
        .i_latchC(i_latchC));
endmodule