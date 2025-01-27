#ifndef TESTS_H
#define TESTS_H

#include "../testbench.h"

// globals
extern VSimTop* top;
extern VerilatedFstC* tfp;

// test functions
int alutest();
int stacktest();

#endif