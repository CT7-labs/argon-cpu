#include "verilated.h"
#include "VArgon.h" // Generated by Verilator from Argon.v
#include "verilated_fst_c.h" // For FST waveform tracing
#include <iostream>

VArgon* top;
VerilatedFstC* tfp; // Trace file pointer
vluint64_t sim_time = 0; // Manual simulation time counter
uint64_t clock_count = 0; // Track clock cycles
bool debug_mode = false;

const int ALU_ADD   = 0;
const int ALU_SUB   = 1;
const int ALU_AND   = 2;
const int ALU_OR    = 3;
const int ALU_XOR   = 4;
const int ALU_SLL   = 5;
const int ALU_SRL   = 6;
const int ALU_SRA   = 7;
const int ALU_SLT   = 8;
const int ALU_SLTU  = 9;

void simClockFall() {
    top->i_clk = 0;
    top->eval();
    tfp->dump(sim_time);
    sim_time++;
    if (debug_mode) {
        std::cout << "Clock fall, time: " << sim_time << "\n";
    }
}

void simClockRise() {
    top->i_clk = 1;
    top->eval();
    tfp->dump(sim_time);
    sim_time++;
    if (debug_mode) {
        std::cout << "Clock rise, time: " << sim_time << "\n";
    }
}

void simClock(int cycles = 1) {
    for (int i = 0; i < cycles; i++) {
        simClockRise();
        simClockFall();
        clock_count++;
    }
}

void simreset() {
    top->i_reset = 1;
    simClock();
    top->i_reset = 0;
    std::cout << "Reset complete\n";
}

void write_register(int reg_num, uint16_t value) {
    top->i_write_en = 1;
    top->i_selectW = reg_num;
    top->i_portW = value;
    top->i_write_to_regfile = 1;
    simClock();
    top->i_write_en = 0;
    std::cout << "Wrote " << value << " to register " << reg_num << "\n";
}

uint16_t read_register(int reg_num) {
    top->i_selectA = reg_num;
    simClock(); // Read takes one cycle to update o_portA
    std::cout << "Read register " << reg_num << ": " << top->o_portA << "\n";
    return top->o_portA;
}

bool test_alu_operation(int op, int regA, int regB, int regW, uint16_t expected_result, const char* op_name) {
    top->i_alu_op = op; // Note: Requires 4-bit i_alu_op in Argon.v
    top->i_selectA = regA;
    top->i_selectB = regB;
    top->i_use_immediate = 0;
    top->i_write_en = 1;
    top->i_selectW = regW;
    top->i_write_to_regfile = 0;
    simClock(2); // Extra cycle for ALU operation and write
    top->i_write_en = 0;

    uint16_t result = read_register(regW);
    bool passed = (result == expected_result);
    std::cout << op_name << " test " << (passed ? "passed" : "failed") 
              << ": got " << result << ", expected " << expected_result << "\n\n";
    return passed;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    top = new VArgon; // Instantiate the top module

    // Initialize FST tracing
    Verilated::traceEverOn(true);
    tfp = new VerilatedFstC;
    top->trace(tfp, 99); // Trace 99 levels of hierarchy
    tfp->open("dump.fst"); // Root directory

    if (!tfp->isOpen()) {
        std::cerr << "Failed to open dump.fst for writing\n";
        delete top;
        return 1;
    }
    std::cout << "Tracing initialized, writing to dump.fst\n";

    std::cout << "\n=== Simulation Begin ===\n";
    simreset();

    // Initialize test state
    top->i_halt = 0;

    // Run tests
    bool all_tests_passed = true;

    // ADD: 42 + 58 = 100
    std::cout << "Loading registers for ADD test...\n";
    write_register(1, 42);
    write_register(2, 58);
    all_tests_passed &= test_alu_operation(ALU_ADD, 1, 2, 3, 100, "ADD");

    // SUB: 100 - 25 = 75
    std::cout << "Loading registers for SUB test...\n";
    write_register(4, 100);
    write_register(5, 25);
    all_tests_passed &= test_alu_operation(ALU_SUB, 4, 5, 6, 75, "SUB");

    // AND: 0xFF00 & 0x0F0F = 0x0F00
    std::cout << "Loading registers for AND test...\n";
    write_register(7, 0xFF00);
    write_register(8, 0x0F0F);
    all_tests_passed &= test_alu_operation(ALU_AND, 7, 8, 9, 0x0F00, "AND");

    // OR: 0xF0F0 | 0x0F0F = 0xFFFF
    std::cout << "Loading registers for OR test...\n";
    write_register(10, 0xF0F0);
    write_register(11, 0x0F0F);
    all_tests_passed &= test_alu_operation(ALU_OR, 10, 11, 12, 0xFFFF, "OR");

    // XOR: 0xFF00 ^ 0x0F0F = 0xF0F0
    std::cout << "Loading registers for XOR test...\n";
    write_register(1, 0xFF00);
    write_register(2, 0x0F0F);
    all_tests_passed &= test_alu_operation(ALU_XOR, 1, 2, 3, 0xF00F, "XOR");

    // SLT: -5 < 10 = 1 (signed)
    std::cout << "Loading registers for SLT test...\n";
    write_register(4, 0xFFFB); // -5 in 16-bit 2's complement
    write_register(5, 10);
    all_tests_passed &= test_alu_operation(ALU_SLT, 4, 5, 6, 1, "SLT");

    // SLTU: 0xFFFB > 10 = 0 (unsigned)
    std::cout << "Loading registers for SLTU test...\n";
    write_register(7, 0xFFFB); // 65531 unsigned
    write_register(8, 10);
    all_tests_passed &= test_alu_operation(ALU_SLTU, 7, 8, 9, 0, "SLTU");

    // SLL: 0x000F << 2 = 0x003C
    std::cout << "Loading registers for SLL test...\n";
    write_register(10, 0x000F);
    write_register(11, 4); // Shift amount in lower 4 bits
    all_tests_passed &= test_alu_operation(ALU_SLL, 10, 11, 12, 0x00F0, "SLL");

    // SRL: 0xF000 >> 2 = 0x3C00
    std::cout << "Loading registers for SRL test...\n";
    write_register(1, 0xF000);
    write_register(2, 4);
    all_tests_passed &= test_alu_operation(ALU_SRL, 1, 2, 3, 0x0F00, "SRL");

    // SRA: 0xF000 >> 2 = 0xFC00 (signed)
    std::cout << "Loading registers for SRA test...\n";
    write_register(4, 0xF000); // -4096 signed
    write_register(5, 2);
    all_tests_passed &= test_alu_operation(ALU_SRA, 4, 5, 6, 0xFC00, "SRA");

    // Cleanup
    std::cout << "Simulation complete, clock cycles: " << clock_count << "\n";
    tfp->close();
    delete tfp;
    delete top;
    if (all_tests_passed) {
        std::cout << "All tests passed!\n";
    } else {
        std::cout << "Some tests failed.\n";
        return 1;
    }
    return 0;
}