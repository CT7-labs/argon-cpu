import argon_pkg::*;

// topmodule for verilator simulation
module SimTop (
    // master I/O
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

    // logic + buses for each module
    logic [15:0] o_bus_alu;
    logic o_bus_valid_alu;
    logic [15:0] o_bus_regfile;
    logic o_bus_valid_regfile;

    // mux buses
    always_comb begin
        if (o_bus_valid_alu)
            o_bus = o_bus_alu;
        else if (o_bus_valid_regfile)
            o_bus = o_bus_regfile;
    end

    assign o_bus_valid = o_bus_alu | o_bus_regfile;

    // instantiate ArgonALU for testing
    ArgonALU inst_ArgonALU (
        // master I/O
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .i_bus(i_bus),
        .o_bus(o_bus_alu),
        .o_bus_valid(o_bus_valid_alu),

        // control wires
        .i_latchA(i_latchA),
        .i_latchB(i_latchB),
        .i_latchF(i_latchF),
        .i_latchOp(i_latchOp),
        .i_outputY(i_outputY),
        .i_outputF(i_outputF));
    
    ArgonRegFile inst_ArgonRegFile (
        // master I/O
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .i_bus(i_bus),
        .o_bus(o_bus_regfile),
        .o_bus_valid(o_bus_valid_regfile),

        // control wires
        .i_selectLatch(i_selectLatch),
        .i_outputA(i_outputA),
        .i_outputB(i_outputB),
        .i_latchC(i_latchC));
endmodule