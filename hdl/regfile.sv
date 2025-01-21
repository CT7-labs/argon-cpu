import argon_pkg::*;

module ArgonRegFile (
    input i_Clk,
    input i_Reset,
    bus_if bus,

    // control wires
    input i_selectLatch,
    input i_outputA,
    input i_outputB,
    input i_latchC);

    // define register file and index registers
    word_t [15:0] regfile [1:REGISTERS-1];
    logic [3:0] indexA, indexB, indexC;

    assign bus.valid = i_outputA | i_outputB;

    always_ff @(posedge i_Clk or posedge i_Reset) begin
        if (i_Reset) begin
            // reset all registers to 0
            for (int i = 1; i<16; i++) begin
                regfile[i] <= 0;
            end

            indexA <= 0;
            indexB <= 0;
            indexC <= 0;
        end

        else begin
            // latch into index select registers
            if (i_selectLatch) begin
                indexA <= bus.i_data[3:0];
                indexB <= bus.i_data[7:4];
                indexC <= bus.i_data[11:8];
            end

            // output proper registers
            else if (i_outputA)
                bus.o_data <= (indexA == 0) ? 16'h0000 : regfile[indexA];
            else if (i_outputB)
                bus.o_data <= (indexB == 0) ? 16'h0000 : regfile[indexB];

            // latch C
            else if (i_latchC && indexC != 0)
                regfile[indexC] <= bus.i_data;
        end
    end
endmodule