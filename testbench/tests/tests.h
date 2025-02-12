#ifndef TESTS_H
#define TESTS_H

#include "../testbench.h"

// globals
extern VSimTop* top;
extern VerilatedFstC* tfp;

// usefuls
void selectRegisters(int a, int b, int c);
int readA();
int readB();
int readF();
void writeC(int value);
void push(int reg);
void pop(int reg);
void compute(int op, int a, int b, int c);

// test functions
int regfile_alu_test();
int memcontroller_test();

#endif