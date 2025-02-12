package memcontroller_pkg;
    // Bus commands
    typedef enum logic [3:0] {
        COM_NOP      = 4'h0, // No operation
        COM_LATCH_MP = 4'h1, // Latch word into MP register
        COM_READ     = 4'h2, // Read word from memory
        COM_WRITE    = 4'h3, // Write word into memory
        COM_TEMP_OUT = 4'h4  // Output temp onto bus
    } command_t;

    typedef enum logic [3:0] {
        ST_READY        = 4'h0, // Ready for commands
        ST_BUSY_READ    = 4'h1, // Reading from memory
        ST_BUSY_WRITE   = 4'h2  // Writing to memory
    } status_t;

    // Memory Map Regions (16-bit address space)
    parameter MMIO_BASE     = 16'h0000; // 256 words of MMIO
    parameter BRAM_BASE     = 16'h0100; // 256 words of cache
    parameter HYPERRAM_BASE = 16'h0200; // 63.5K words of HyperRAM

    // Memory-Mapped Register Offsets
    parameter MM_REGISTER_COUNT = 3;
    parameter MM_BANK_SEL     = 8'h00;  // Bank selection
    parameter MM_STATUS       = 8'h01;  // Status register
    parameter MM_CONTROL      = 8'h02;  // Global control

endpackage