#ifndef TEST_FUNCTION_H
#define TEST_FUNCTION_H

#include "VSimTop.h"
#include "verilated_fst_c.h"
#include <iostream>
#include "constants.h"

// shared simulation functions
void simClockFall();
void simClockRise();
void simClock(int i = 1);
void simReset();

// test functions
void add37(VSimTop* top, VerilatedFstC* tfp);
int regfile_test0(VSimTop* top, VerilatedFstC* tfp);

#endif