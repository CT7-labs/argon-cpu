module InterruptFilter (
    input i_clk,
    input logic i_trigger,
    input logic i_ack,
    input logic i_en,
    output logic o_int
);

    /*
    Argon interrupts work like so when i_en is high:
    Once i_trigger is detected to be high and i_en is high, o_int is latched high until i_ack goes high, then o_int reset to 0
    */

    always_ff @(posedge i_clk) begin
        if (i_en && i_trigger && ~o_int) begin
            o_int <= 1'b1;
        end

        if (o_int && i_ack) begin
            o_int <= 1'b0;
        end
    end
    
endmodule