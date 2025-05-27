module Memory (
    input wire i_clk,
    
    input wire [31:0] i_address,
    input wire i_we,
    input wire [31:0] i_wr_data,
    output wire [31:0] o_rd_data,
);

    reg [31:0] mem [0:1023];
    reg [31:0] rdata;
    wire [9:0] raddr = i_address[12:2];

    always @(posedge i_clk) begin
        rdata <= mem[raddr];
        if (i_we) mem[raddr] <= i_wr_data;
    end

    assign o_rd_data = rdata;
    
endmodule