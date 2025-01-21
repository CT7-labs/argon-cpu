/*
Register file 15x 16-bit registers and a zero register

r0      Zero register
r1-15   General-purpose registers
*/

module ArgonRegfile (
    // master ports
    input i_Clk,
    input i_Reset,
    input [15:0] i_bus,
    output [15:0] o_bus,
    output o_bus_valid,

    // control wires
    input i_selectLatch,
    input i_outputA,
    input i_outputB,
    input i_latchC);

    // let external circuitry know when the regfile is outputing data
    assign o_bus_valid = i_outputA | i_outputB;

    // 16x 16-bit registers
    logic [15:0] regfile [1:15];
    logic [3:0] indexA, indexB, indexC;

    always_ff @(posedge i_Clk or posedge i_Reset) begin
        if (i_Reset) begin
            // reset all registers to 0
            for (i = 1; i<16; i++) begin
                regfile[i] <= 0;
            end

            indexA <= 0;
            indexB <= 0;
            indexC <= 0;
        end

        else begin
            // latch into index select registers
            if (i_selectLatch) begin
                indexA <= i_bus[3:0];
                indexB <= i_bus[7:4];
                indexC <= i_bus[11:8];
            end

            // output proper registers
            else if (i_outputA)
                o_bus <= (indexA == 0) ? 16'h0000 : regfile[indexA];
            else if (i_outputB)
                o_bus <= (indexB == 0) ? 16'h0000 : regfile[indexB];

            // latch C
            else if (i_latchC && indexC != 0)
                regfile[indexC] <= i_bus;
        end
    end
    
endmodule