package regfile_pkg;
    // ALU regfile input command constants

    // 0 is NOP
    parameter COM_READA     = 4'h1;
    parameter COM_READB     = 4'h2;
    parameter COM_LATCHC    = 4'h3;
    parameter COM_LATCHSEL  = 4'h4;
    parameter COM_READSP    = 4'h5;
    parameter COM_READF     = 4'h6;
    parameter COM_SPINC     = 4'h7;
    parameter COM_SPDEC     = 4'h8;

    parameter REGISTERS     = 8;
    parameter INDEX_WIDTH   = 3;

    parameter R_SP          = 6;
    parameter R_F           = 7;

endpackage
