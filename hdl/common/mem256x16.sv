module Mem256x16 (
    input wire clk,
    input wire rd_en,
    input wire wr_en,
    input wire [7:0] rd_addr,
    input wire [7:0] wr_addr,
    input wire [15:0] data_in,
    output reg [15:0] data_out,
    output reg valid_out
);
    
    reg [15:0] memory [0:255];
    
    // remove these mem_N registers
    word_t mem_0 = memory[0];
    word_t mem_1 = memory[1];
    word_t mem_2 = memory[2];
    word_t mem_3 = memory[3];
    word_t mem_4 = memory[4];

    // Registered outputs to match SB_RAM256x16
    always @(posedge clk) begin
        if (rd_en) begin
            data_out <= memory[rd_addr];
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

    // Write port
    always @(posedge clk) begin
        if (wr_en) begin
            memory[wr_addr] <= data_in;
        end
    end

endmodule