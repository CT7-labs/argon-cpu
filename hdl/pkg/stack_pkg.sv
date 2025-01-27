package stack_pkg;
    // ALU regfile input command constants

    // 0 is NOP
    parameter COM_PUSH      = 4'h1;
    parameter COM_POP       = 4'h2;
    parameter COM_LOAD_PTR  = 4'h3;
    parameter COM_READ_PTR  = 4'h4;

endpackage
