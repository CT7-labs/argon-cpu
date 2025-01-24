package regfile_pkg;
    // ALU regfile input command constants

    // 0 is NOP
    parameter COM_READA     = 'h1;
    parameter COM_READB     = 'h2;
    parameter COM_LATCHC    = 'h3;
    parameter COM_LATCHSEL  = 'h4;
    parameter COM_READSP    = 'h5;
    parameter COM_READF     = 'h6;
    parameter COM_SP_INC    = 'h7;
    parameter COM_SP_DEC    = 'h8;
    parameter COM_LATCHSP   = 'h9;
    parameter COM_LATCHF    = 'hA;
    parameter COM_READRV    = 'hB;
    parameter COM_LATCHRV   = 'hC;

    parameter REGISTERS     = 8;
    parameter INDEX_WIDTH   = 3;

    parameter RV           = 7;
    parameter SP          = 6;
    parameter F           = 7;

endpackage
