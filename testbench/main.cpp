// important includes
#include "constants.h"
#include "testbench.h"

using namespace std;
using namespace std::chrono;

int main(int argc, char** argv) {
    bool fromMake = false;

    for (int i = 1; i < argc; i++) {
        if (std::string(argv[i]) == "--fromMake") {
            fromMake = true;
        }
    }

    if (fromMake) {
        cout << "\n";
    }

    initTestbench(argc, argv);
    runTest();
    cleanup();

    return 0;
}