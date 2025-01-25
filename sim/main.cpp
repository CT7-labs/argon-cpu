// important includes
#include "constants.h"
#include "testbench.h"

using namespace std;
using namespace std::chrono;

int main(int argc, char** argv) {
    cout << "Simulation worked\n";

    initTestbench(argc, argv);
    simClock(1000);
    runTest();
    simClock(1000);
    cleanup();

    return 0;
}