package stack_pkg;
    // Stack Commands
    typedef enum logic [3:0] {
        COM_NOP      = 4'h0,  // No operation
        COM_PUSH     = 4'h1,  // Push value onto stack
        COM_POP      = 4'h2,  // Pop value from stack
        COM_LOAD_PTR = 4'h3,  // Load stack pointer with new value
        COM_READ_PTR = 4'h4   // Read current stack pointer value
    } stack_command_t;

endpackage