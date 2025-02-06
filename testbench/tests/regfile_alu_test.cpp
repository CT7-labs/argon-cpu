#include "tests.h"

int regfile_alu_test() {
    simReset();

    // LDF 1 (carry flag)
    selectRegisters(0, 0, R_F);
    writeC(ALU::F_CARRY);

    // LDA 12
    selectRegisters(0, 0, R_GP1);
    writeC(12);

    // LDB 25
    selectRegisters(0, 0, R_GP2);
    writeC(25);
    
    // compute A + B
    compute(ALU::OP_ADC, R_GP1, R_GP2, R_GP1);

    std::cout << readA() << "\n";
    std::cout << readF() << "\n";

    // push to stack
    push(R_GP1);
    push(R_F);

    // pop result into GP3
    pop(R_GP3);
    selectRegisters(R_GP3, 0, 0);
    std::cout << "\n" << readA() << "\n";
    pop(R_GP3);
    selectRegisters(R_GP3, 0, 0);
    std::cout << "\n" << readA() << "\n";

    simReset();
    return 0;
}