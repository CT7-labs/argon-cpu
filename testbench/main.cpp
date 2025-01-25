// important includes
#include "constants.h"
#include "testbench.h"

using namespace std;
using namespace std::chrono;

int main(int argc, char** argv) {
    initTestbench(argc, argv);
    runTest();
    cleanup();

    return 0;
}