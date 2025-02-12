import constants_pkg::*;
import memcontroller_pkg::*;

module ArgonMemController (
    input i_Clk,
    input i_Reset,
    bus_if bus_if,

    // memcontroller <-> control unit interface
    output logic [3:0] o_status);

    // memcontroller registers
    word_t temp, mp;
    status_t status;

    // memory mapped registers
    word_t mmio [0:MM_REGISTER_COUNT];

    // comb logic
    always_comb begin
        // defaults
        bus_if.o_valid = 0;
        bus_if.o_data = '0;

        o_status = '0;

        if (bus_if.command == COM_TEMP_OUT) begin
            bus_if.o_valid = 1;
            bus_if.o_data = temp;
        end
    end

    always_ff @(posedge i_Clk or posedge i_Reset ) begin

        if (i_Reset) begin
            // reset registers
            temp <= '0;
            mp <= '0;
            status <= '0;

            // reset MMIO registers
            for (int i = 0; i < MM_REGISTER_COUNT; i ++) begin
                mmio[i] <= '0;
            end

        end else begin

            // handle memory pointer latching
            if (bus_if.command == COM_LATCH_MP) begin
                mp <= bus_if.i_data;
            end

            // handle reading from MMIO
            if (bus_if.command == COM_READ) begin
                if (MMIO_BASE < mp < MM_REGISTER_COUNT) begin
                    temp <= mmio[mp];
                end
            end

            // handle writing to MMIO
            if (bus_if.command == COM_WRITE) begin
                if (MMIO_BASE < mp < MM_REGISTER_COUNT) begin
                    mmio[mp] <= bus_if.i_data;
                end
            end
        end
    end
endmodule