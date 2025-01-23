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
void simReset(int i = 1);

// test functions
void add37(VSimTop* top, VerilatedFstC* tfp);

#endif