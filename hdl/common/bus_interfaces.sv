import constants_pkg::*;

// interfaces
interface master_bus_if;
    word_t i_data; // input to module
    logic i_valid;
    word_t o_data; // output from module
    logic o_valid;

    logic [3:0] write_id; // selects which module outputs onto i_data
    logic [3:0] read_id; // selects which module reads from i_data
    logic [3:0] write_command; // command for the selected write module
    logic [3:0] read_command; // command for the selected read module
endinterface

interface bus_if;
    word_t i_data; // input to module
    logic i_valid;
    word_t o_data; // output from module
    logic o_valid;

    logic [3:0] command; // command for module
    logic [3:0] error;
endinterface
