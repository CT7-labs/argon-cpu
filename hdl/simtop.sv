import constants_pkg::*;

module SimTop (
    input i_Clk,
    input i_Reset,

    // for testing simulating with verilator
    output word_t i_debug, // inputs data to the verilator simulation
    output i_debug_valid, // inputs "data valid" signal to the verilator simulation
    input word_t o_debug,
    input o_debug_valid,

    // control unit will take over these ports
    input [3:0] write_id,
    input [3:0] read_id,
    input [3:0] write_command,
    input [3:0] read_command);

    // bus interfaces
    master_bus_if master_bus();
    assign master_bus.read_id = read_id;
    assign master_bus.write_id = write_id;
    assign master_bus.read_command = read_command;
    assign master_bus.write_command = write_command;

    bus_if alu_bus();
    bus_if regfile_bus();
    bus_if debug_bus();
    assign i_debug = debug_bus.i_data;
    assign i_debug_valid = debug_bus.i_valid;
    assign debug_bus.o_data = o_debug;
    assign debug_bus.o_valid = o_debug_valid;

    // this is a test I really wanna test this
    // AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

    always_comb begin
        // define defaults (prevent latches)
        master_bus.o_data = 0;
        master_bus.o_valid = 0;

        // handle units writing to the bus
        case (write_id)
            ID_ALU: begin
                if (alu_bus.o_valid) begin
                    master_bus.o_data = alu_bus.o_data;
                    master_bus.o_valid = alu_bus.o_valid;
                end

                alu_bus.command = write_command;
            end

            ID_REGFILE: begin
                if (regfile_bus.o_valid) begin
                    master_bus.o_data = regfile_bus.o_data;
                    master_bus.o_valid = regfile_bus.o_valid;
                end

                regfile_bus.command = write_command;
            end

            ID_DEBUG: begin
                if (debug_bus.o_valid) begin
                    master_bus.o_data = debug_bus.o_data;
                    master_bus.o_valid = debug_bus.o_valid;
                end
            end

            default: begin
                alu_bus.command = 0;
                regfile_bus.command = 0;
            end
        endcase

        // handle units reading from the bus
        case (read_id)
            ID_ALU: begin
                alu_bus.i_data = master_bus.o_data;
                alu_bus.i_valid = master_bus.o_valid;
                alu_bus.command = master_bus.read_command;
            end

            ID_REGFILE: begin
                regfile_bus.i_data = master_bus.o_data;
                regfile_bus.i_valid = master_bus.o_valid;
                regfile_bus.command = master_bus.read_command;
            end

            ID_DEBUG: begin
                debug_bus.i_data = master_bus.o_data;
                debug_bus.i_valid = master_bus.o_valid;
            end

            default: begin
                master_bus.i_data = master_bus.o_data;
                master_bus.i_valid = 0;

                alu_bus.command = 0;
                regfile_bus.command = 0;
            end
        endcase
    end

    // device instances

    // ALU
    ArgonALU inst_ArgonALU (
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .bus_if(alu_bus));

    ArgonRegFile inst_ArgonRegFile (
        .i_Clk(i_Clk),
        .i_Reset(i_Reset),
        .bus_if(regfile_bus));

endmodule