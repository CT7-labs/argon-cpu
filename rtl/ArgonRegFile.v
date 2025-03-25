/*
=== ArgonRegFile Features ===
- Variable register count
- Variable data width
- Zero register (address 0)
*/

module ArgonRegFile #(parameter REGISTERS = 8, INDEXWIDTH = 3, DATAWIDTH=16) (
    // Control wires
    input wire i_clk,
    input wire i_reset,
    input wire i_writeEn,

    // Address select wires
    input wire [INDEXWIDTH-1:0] i_selectA,
    input wire [INDEXWIDTH-1:0] i_selectB,
    input wire [INDEXWIDTH-1:0] i_selectW,

    // Data wires
    input reg [DATAWIDTH-1:0] i_wdata,
    output reg [DATAWIDTH-1:0] o_rdataA,
    output reg [DATAWIDTH-1:0] o_rdataB
);

    reg [DATAWIDTH-1:0] regfile [1:REGISTERS-1];

    // Clocked logic
    integer i;
    always @(posedge i_clk or posedge i_reset) begin
        
        // Reset logic
        if (i_reset) begin
            for (i = 1; i < REGISTERS; i = i + 1) begin
                regfile[i] = 0;
            end
        end

        // Write logic
        else begin
            if (i_writeEn && i_selectW > 0) begin
                regfile[i_selectW] <= i_wdata;
            end
        end
    end

    // Output logic
    assign o_rdataA = (i_selectA > 0) ? regfile[i_selectA] : 0;
    assign o_rdataB = (i_selectB > 0) ? regfile[i_selectB] : 0;

endmodule