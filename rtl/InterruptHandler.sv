module InterruptHandler (
    input i_clk,
    input logic [3:0] i_trigger,
    input logic i_ack,
    output logic o_int,
    input logic [31:0] i_wr_port,
    input logic [2:0] i_addr,
    input logic i_wr_en,
    output logic [31:0] o_addr
);

    logic [3:0] en_mask;
    logic [3:0] int_mask;
    logic [3:0] ack_mask;
    logic [31:0] int_addr [0:3];

    InterruptFilter intfilter_inst0 (
        .i_clk(i_clk),
        .i_trigger(i_trigger[0]),
        .i_ack(ack_mask[0]),
        .i_en(en_mask[0]),
        .o_int(int_mask[0])
    );

    InterruptFilter intfilter_inst1 (
        .i_clk(i_clk),
        .i_trigger(i_trigger[1]),
        .i_ack(ack_mask[1]),
        .i_en(en_mask[1]),
        .o_int(int_mask[1])
    );

    InterruptFilter intfilter_inst2 (
        .i_clk(i_clk),
        .i_trigger(i_trigger[2]),
        .i_ack(ack_mask[2]),
        .i_en(en_mask[2]),
        .o_int(int_mask[2])
    );

    InterruptFilter intfilter_inst3 (
        .i_clk(i_clk),
        .i_trigger(i_trigger[3]),
        .i_ack(ack_mask[3]),
        .i_en(en_mask[3]),
        .o_int(int_mask[3])
    );

    always_ff @(posedge i_clk) begin
        
    end
    
endmodule