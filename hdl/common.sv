import argon_pkg::*;

// interfaces
interface master_bus_if;
    word_t i_data;
    word_t o_data;
    logic i_valid;
    logic o_valid;
    logic [3:0] write_id;
    logic [3:0] read_id;
endinterface

interface bus_if;
    word_t i_data;
    word_t o_data;
    logic i_valid;
    logic o_valid;
endinterface

module BusBuffer #(
    parameter UNIT_ID = 4'h1
)(
    master_bus_if mbus,
    bus_if ubus);

    always_comb begin

        if (mbus.write_id == UNIT_ID)
            ubus.i_data = mbus.o_data;
        
        if (mbus.read_id == UNIT_ID) begin
            mbus.o_data = ubus.o_data;
        end
    end

endmodule