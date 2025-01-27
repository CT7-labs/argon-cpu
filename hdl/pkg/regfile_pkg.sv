package regfile_pkg;
    // ALU regfile input command constants

    // 0 is NOP
    parameter COM_READA     = 'h1;
    parameter COM_READB     = 'h2;
    parameter COM_LATCHC    = 'h3;
    parameter COM_LATCHSEL  = 'h4;
    parameter COM_READSP    = 'h5;
    parameter COM_READF     = 'h6;
    parameter COM_READRV    = 'h7;
    parameter COM_LATCHSP   = 'h8;
    parameter COM_LATCHF    = 'h9;
    parameter COM_LATCHRV   = 'hA;

    parameter REGISTERS     = 8;
    parameter INDEX_WIDTH   = 3;

    parameter RV    = 5;
    parameter SP    = 6;
    parameter F     = 7;

endpackage
