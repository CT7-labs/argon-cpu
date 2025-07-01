module ArgonTB (
    input wire i_clk,
    input wire i_halt,
    input wire i_reset
);

    Argon argon_inst (
        .i_clk(i_clk),
        .i_halt(i_halt),
        .i_reset(i_reset),

        // Memory control port
        

    );

    logic [31:0] w_mem_address, w_mem_wr_data, w_mem_rd_data;
    logic [1:0] w_mem_wr_mask;
    logic [2:0] w_mem_rd_mask;
    logic w_mem_err_address_misaligned, w_mem_err_invalid_read_mask;

    Memory memory_inst (
        .i_clk(i_clk),
        .i_reset(i_reset),
        
        .i_address(w_mem_address),
        // write port
        .i_wr_data(w_mem_wr_data),
        .i_wr_mask(w_mem_wr_mask),

        // read port
        .i_rd_data(w_mem_rd_data),
        .i_rd_mask(w_mem_rd_mask),

        // error port
        .o_err_address_misaligned(w_mem_err_address_misaligned),
        .o_err_invalid_read_mask(w_mem_err_invalid_read_mask)
    );
    
endmodule