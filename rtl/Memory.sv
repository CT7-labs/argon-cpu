parameter WRMASK_N = 0; // Disable write
parameter WRMASK_B = 1; // Write the lower 8 bits from i_wr_data
parameter WRMASK_H = 2; // Write the lower 16 bits from i_wr_data
parameter WRMASK_W = 3; // Write the full 32-bit word from i_wr_data

parameter RDMASK_W = 0; // Word read
parameter RDMASK_HZ = 1; // Zero ext. Half read
parameter RDMASK_BZ = 2; // Zero ext. Byte read
parameter RDMASK_HE = 3; // Sign ext. half read
parameter RDMASK_BE = 4; // Sign ext. byte read


module Memory (
    input wire i_clk,
    input wire i_reset,
    
    input logic [31:0] i_address,
    input logic [31:0] i_wr_data,
    input logic [1:0] i_wr_mask,
    input logic [2:0] i_rd_mask,
    output logic [31:0] o_rd_data,
    output logic o_err_address_misaligned, o_err_invalid_read_mask
);

    reg [7:0] mem0 [0:1023];
    reg [7:0] mem1 [0:1023];
    reg [7:0] mem2 [0:1023];
    reg [7:0] mem3 [0:1023];

    initial begin
        // Memory initialization
        // Left blank intentionally for now
    end

    logic [9:0] w_address; // 9-bit address for now
    assign w_address = i_address[11:2];

    assign debug_mem0 = {mem0[0], mem1[0], mem2[0], mem3[0]};
    assign debug_mem1 = {mem0[1], mem1[1], mem2[1], mem3[1]};
    assign debug_mem2 = {mem0[2], mem1[2], mem2[2], mem3[2]};

    always @(posedge i_clk) begin
        // Base error state
        o_err_address_misaligned <= 0;
        o_err_invalid_read_mask <= 0;
        
        // Read little-Endian data as big-Endian
        if (i_rd_mask == RDMASK_W) begin
            o_rd_data <= {mem3[w_address], mem2[w_address], mem1[w_address], mem0[w_address]};
        end else if (i_rd_mask == RDMASK_HZ) begin
            case (i_address[1])
                1'b0: o_rd_data <= {16'b0, mem1[w_address], mem0[w_address]};
                1'b1: o_rd_data <= {16'b0, mem3[w_address], mem2[w_address]};
            endcase
        end else if (i_rd_mask == RDMASK_BZ) begin
            case (i_address[1:0])
                2'b00: o_rd_data <= {24'b0, mem0[w_address]};
                2'b01: o_rd_data <= {24'b0, mem1[w_address]};
                2'b10: o_rd_data <= {24'b0, mem2[w_address]};
                2'b11: o_rd_data <= {24'b0, mem3[w_address]};
            endcase
        end else if (i_rd_mask == RDMASK_HE) begin
            case (i_address[1])
                1'b0: o_rd_data <= {{16{mem1[w_address][7]}}, mem1[w_address], mem0[w_address]};
                1'b1: o_rd_data <= {{16{mem3[w_address][7]}}, mem3[w_address], mem2[w_address]};
            endcase
        end else if (i_rd_mask == RDMASK_BE) begin
            case (i_address[1:0])
                2'b00: o_rd_data <= {{24{mem0[w_address][7]}}, mem0[w_address]};
                2'b01: o_rd_data <= {{24{mem1[w_address][7]}}, mem1[w_address]};
                2'b10: o_rd_data <= {{24{mem2[w_address][7]}}, mem2[w_address]};
                2'b11: o_rd_data <= {{24{mem3[w_address][7]}}, mem3[w_address]};
            endcase
        end else begin
            o_err_invalid_read_mask <= 1;
        end
        

        // Write data
        if (i_wr_mask == WRMASK_W) begin
            // Write in little-Endian order
            mem0[w_address] <= i_wr_data[7:0];
            mem1[w_address] <= i_wr_data[15:8];
            mem2[w_address] <= i_wr_data[23:16];
            mem3[w_address] <= i_wr_data[31:24];

        end else if (i_wr_mask == WRMASK_H) begin
            if (i_address[0] == 0) begin
                case (i_address[1])
                    1'b0: begin
                        mem0[w_address] <= i_wr_data[7:0];
                        mem1[w_address] <= i_wr_data[15:8];
                    end
                    1'b1: begin
                        mem2[w_address] <= i_wr_data[7:0];
                        mem3[w_address] <= i_wr_data[15:8];
                    end
                endcase
            end else begin
                o_err_address_misaligned <= 1;
            end
            
        end else if (i_wr_mask == WRMASK_B) begin
            case (i_address[1:0])
                2'b00: mem0[w_address] <= i_wr_data[7:0];
                2'b01: mem1[w_address] <= i_wr_data[7:0];
                2'b10: mem2[w_address] <= i_wr_data[7:0];
                2'b11: mem3[w_address] <= i_wr_data[7:0];
            endcase
        end
    end
endmodule