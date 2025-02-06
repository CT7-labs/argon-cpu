// smaller package so things don't have to be edited in two files
package regfile_alu_shared_pkg;
    // Write select control for ALU
    typedef enum logic [1:0] {
        WSEL_NONE = 2'b00,
        WSEL_REGC = 2'b01,
        WSEL_REGF = 2'b10,
        WSEL_RFU  = 2'b11   // Reserved for future use
    } write_sel_t;
endpackage

package regfile_pkg;
    // Number of registers and index width
    parameter REGISTERS     = 8;
    parameter INDEX_WIDTH   = 3;

    parameter RV    = 5;
    parameter SP    = 7;
    parameter F     = 6;

    typedef enum logic [3:0] {
        COM_READA       = 1,
        COM_READB       = 2,
        COM_LATCHC      = 3,
        COM_LATCHSEL    = 4,
        COM_READF       = 5,
        COM_ALU_WE      = 6,
        COM_SP_WE       = 7
    } reg_com_t;


    // Register addresses
    typedef enum logic [INDEX_WIDTH-1:0] {
        R_ZERO = 3'b000,  // Zero register
        R_GP1  = 3'b001,  // General purpose 1
        R_GP2  = 3'b010,  // General purpose 2
        R_GP3  = 3'b011,  // General purpose 3
        R_GP4  = 3'b100,  // General purpose 4
        R_GP5  = 3'b101,  // General purpose 5
        R_SP   = 3'b110,  // Stack pointer
        R_F    = 3'b111   // Flags register
    } reg_addr_t;

endpackage