import constants_pkg::*;

module ScratchpadMem (
    input i_Clk,
    input i_Reset,
    
    // interface with memcontroller
    input word_t i_address,
    input word_t i_data,
    output word_t o_data,
    input i_read_en,
    input i_write_en,
    output o_valid_data,
    input i_enable
);

    // Generate single read/write enable
    logic [3:0] page_sel;
    logic page_read_en, page_write_en;
    word_t page_data [0:3];
    logic [3:0] page_valid;

    // Page select decoder
    always_comb begin
        page_sel = 4'b0;
        if (i_enable)
            page_sel = 4'b0001 << i_address[9:8];
    end

    // Enable signals for each page
    assign page_read_en = i_read_en & i_enable;
    assign page_write_en = i_write_en & i_enable;

    // Generate 4 pages
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : mem_pages
            Mem256x16 page (
                .clk(i_Clk),
                .rd_en(page_read_en & page_sel[i]),
                .wr_en(page_write_en & page_sel[i]),
                .rd_addr(i_address[7:0]),
                .wr_addr(i_address[7:0]),
                .data_in(i_data),
                .data_out(page_data[i]),
                .valid_out(page_valid[i])
            );
        end
    endgenerate

    // Output mux
    assign o_data = page_data[i_address[9:8]];
    assign o_valid_data = page_valid[i_address[9:8]];

endmodule