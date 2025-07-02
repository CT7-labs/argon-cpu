void write_word(int addr, int data) {
    top->i_wr_mask = 3;
    top->i_address = addr;
    top->i_wr_data = data & 0xFFFFFFFF;
    simClock();
}

void write_half(int addr, int data) {
    top->i_wr_mask = 2;
    top->i_address = addr;
    top->i_wr_data = data & 0xFFFFFFFF;
    simClock();
}

void write_byte(int addr, int data) {
    top->i_wr_mask = 1;
    top->i_address = addr;
    top->i_wr_data = data & 0xFFFFFFFF;
    simClock();
}

void write_nothing(int addr, int data = 0xAAFFAAFF) {
    top->i_wr_mask = 0;
    top->i_address = addr;
    top->i_wr_data = data; // If the address is overwritten with this, something is wrong
    simClock();
}

void print_mem(int addr) {
    printf("0x%08x\n", top->o_rd_data);
}

void read_mem(int addr, int mask) {
    top->i_wr_mask = 0;
    top->i_address = addr;
    top->i_wr_data = 0;
    top->i_rd_mask = mask;
    simClock(2); // 1 for address delay, 1 for latching output
    printf("0x%08x\n", top->o_rd_data);
}