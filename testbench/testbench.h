#ifndef TESTBENCH_H
#define TESTBENCH_H

// verilator shenanigans
#include <verilated.h>
#include "verilated_fst_c.h"
#include "VSimTop.h"

// stdlib tomfoolery
#include <iostream>
#include <chrono>
#include <string.h>
#include <iomanip>

#include "constants.h"

// testbench functions
void simClockFall();
void simClockRise();
void simClock(int i = 1);
void simReset();

void initTestbench(int argc, char** argv);
void runTest();
void cleanup();

#endif