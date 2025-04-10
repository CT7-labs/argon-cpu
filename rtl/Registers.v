// Registers.v

module Registers (
    input wire i_clk,
    input wire i_reset,

    // control ports
    input wire i_write_en,
    input wire [3:0] i_selectA,
    input wire [3:0] i_selectB,
    input wire [3:0] i_selectW,

    // data ports
    output reg [15:0] o_portA,
    output reg [15:0] o_portB,
    input wire [15:0] i_portW
);

    reg [15:0] registers [1:15];

    integer i;
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            for (i = 1; i <= 15; i = i + 1) begin
                registers[i] <= 16'h0;
            end
        end else begin
            if (i_write_en && i_selectW > 4'h0) begin
                registers[i_selectW] <= i_portW;
            end
        end
    end

    always @(posedge i_clk) begin
        // Synchronous reads for future pipelining implementation
        o_portA <= (i_selectA > 0) ? registers[i_selectA] : 16'h0;
        o_portB <= (i_selectB > 0) ? registers[i_selectB] : 16'h0;
    end
    
endmodule