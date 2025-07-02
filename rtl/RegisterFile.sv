module RegisterFile (
    input wire i_clk,
    input wire i_reset,
    input logic i_write_en,
    
    input logic [4:0] i_selectA,
    input logic [4:0] i_selectB,
    input logic [4:0] i_selectW,

    output logic [31:0] o_portA,
    output logic [31:0] o_portB,
    input logic [31:0] i_portW
);

    reg [31:0] file [1:31];

    assign o_portA = (i_selectA > 0) ? file[i_selectA] : 32'h0;
    assign o_portB = (i_selectB > 0) ? file[i_selectB] : 32'h0; 

    // read from the register file
    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            // handle reset logic
            for (integer i = 1; i < 32; i = i + 1) begin
                file[i] <= 32'h0;
            end

        end else begin
            // handle clocked logic
            if ((i_selectW > 0) && (i_write_en)) begin
                file[i_selectW] <= i_portW;
            end

        end
    end
    
endmodule