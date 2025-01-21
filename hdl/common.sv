import argon_pkg::*;

// interfaces
interface bus_if;
    word_t i_data;
    word_t o_data;
    logic valid;
endinterface
