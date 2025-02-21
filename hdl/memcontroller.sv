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
        o_status = status;

        // output temporary register
        if (bus_if.command == COM_TEMP_OUT) begin
            bus_if.o_valid = 1;
            bus_if.o_data = temp;
        end
    end

    // state machine registers
    logic [3:0] state;

    always_ff @(posedge i_Clk or posedge i_Reset ) begin

        if (i_Reset) begin
            // reset registers
            temp <= '0;
            mp <= '0;
            status <= '0;

            // reset MMIO registers
            for (int i = SCRATCH_BASE; i ++; i < SCRATCH_BASE + SCRATCH_SIZE) begin
                mmio[i] <= '0;
            end

        end else begin
            // default status value
            status <= ST_READY;

            // handle memory pointer latching
            if (bus_if.command == COM_LATCH_MP) begin
                mp <= bus_if.i_data;
            end

            // handle reading
            else if (bus_if.command == COM_READ) begin

                // handle reading from MMIO
                if (MMIO_BASE < mp < MMIO_BASE + MM_REGISTER_COUNT) begin
                    status <= ST_BUSY_READ;
                    temp <= mmio[mp];
                end

                // handle reading from scratchpad memory
                else if (SCRATCH_BASE < mp < SCRATCH_BASE + SCRATCH_SIZE) begin
                    status <= ST_BUSY_READ;
                    
                    // latch address into scratchpad (already done I think)

                    case (state)
                        // latch scratchpad into temp
                        4'h0: begin
                            if (scratch_valid) temp <= scratch_out;
                            state ++;
                        end

                        // set status to READY
                        4'h1: begin
                            status <= ST_READY;
                            state <= 0;
                        end
                    endcase
                end
                
                // mp overflow
                else begin
                    temp <= '0;
                    status <= ST_MP_OVERFLOW;
                end
            end

            // handle writing
            else if (bus_if.command == COM_WRITE) begin
                status <= ST_BUSY_WRITE;

                // handle writing to MMIO
                if (MMIO_BASE < mp < MM_REGISTER_COUNT) begin
                    mmio[mp] <= bus_if.i_data;
                end

                // handle writing to scratchpad memory
                else if (SCRATCH_BASE < mp < SCRATCH_BASE + SCRATCH_SIZE) begin
                    status <= ST_BUSY_READ;
                    
                    // latch address into scratchpad (already done I think)

                    case (state)
                        // latch data into scratchpad
                        4'h0: state ++;

                        // finish
                        4'h1: begin
                            status <= ST_READY;
                            state <= 0;
                        end

                    endcase
                end
            end
        end
    end

    // scratchpad memory
    word_t scratch_out;
    logic scratch_re, scratch_we, scratch_valid, scratch_en;

    ScratchpadMem inst_ScratchpadMem(
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .i_address(mp),
        .i_data(bus_if.i_data),
        .o_data(scratch_out),
        .i_read_en(scratch_re),
        .i_write_en(scratch_we),
        .o_valid_data(scratch_valid),
        .i_enable(scratch_en)
    );
endmodule