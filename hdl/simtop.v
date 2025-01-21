// topmodule for verilator simulation
module SimTop (
    // master I/O
    input i_Clk,
    input i_Reset,
    input [15:0] i_bus,
    output [15:0] o_bus,

    // for testing/simulating in Verilator
    input i_latchA,
    input i_latchB,
    input i_latchF,
    input i_latchOp,
    input i_outputY,
    input i_outputF,
    output o_bus_valid);

    // instantiate ArgonALU for testing
    ArgonALU inst_ArgonALU (
        // master I/O
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .i_bus(i_bus),
        .o_bus(o_bus),
        .o_bus_valid(o_bus_valid),

        // control wires
        .i_latchA(i_latchA),
        .i_latchB(i_latchB),
        .i_latchF(i_latchF),
        .i_latchOp(i_latchOp),
        .i_outputY(i_outputY),
        .i_outputF(i_outputF));
endmodule