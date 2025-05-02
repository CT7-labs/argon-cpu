module Memory (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    output reg  [15:0] o_memory_data,
    input  wire [15:0] i_memory_data,
    input  wire [15:0] i_memory_address,
    input  wire i_memory_re,
    input  wire i_memory_we
);

    // Clock wire
    wire sys_clk;
    assign sys_clk = (i_clk & ~i_halt);

    // Memory
    reg [15:0] memory [0:255];
    $initial begin
        $readmemh("some_data.hex", memory); // placeholder file, obviously
    end

    wire [7:0] raddr = i_memory_address[7:0];
    always @(posedge sys) begin
        o_memory_data <= memory[raddr];
    end
    
endmodule