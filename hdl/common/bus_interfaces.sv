import constants_pkg::*;

// interfaces
interface master_bus_if;
    word_t i_data;
    word_t o_data;
    logic i_valid;
    logic o_valid;
    logic [3:0] write_id;
    logic [3:0] read_id;
    logic [3:0] write_command;
    logic [3:0] read_command;
endinterface

interface bus_if;
    word_t i_data;
    word_t o_data;
    logic i_valid;
    logic o_valid;
    logic [3:0] command;
    logic [3:0] error;
endinterface
