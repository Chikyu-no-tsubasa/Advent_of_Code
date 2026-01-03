/*
https://adventofcode.com/2024/day/2
To compile and run:
g++ Day2_2.cpp -o Day2_2
./Day2_2
*/

#include <iostream>   // for console input/output (cout, cerr)
#include <fstream>    // for file input/output (ifstream)
#include <sstream>    // for reading data from a line (stringstream)
#include <string>     // for using std::string
#include <cstdlib>    // for labs()
using namespace std;

int main()
{
    // Open the input file containing the puzzle data
    ifstream file("input.txt");

    // Check if the file opened successfully
    if (!file)
    {
        cerr << "Error during file opening\n";
        return 1;  // Exit with error code 1
    }

    long totalSafeRepo = 0;  // Counter for the number of safe reports

    string line;
    // Read the file line by line
    while (getline(file, line))
    {
        if (line.empty())
            continue;

        // 1) Count how many numbers are in this line (no storage)
        int len = 0;
        {
            stringstream countSS(line);
            long t;
            while (countSS >> t) ++len;
        }

        // 2) Try every possible single removal: skipIdx = -1 means "remove none"
        bool lineIsSafe = false;
        for (int skipIdx = -1; skipIdx < len && !lineIsSafe; ++skipIdx)
        {
            stringstream ss(line);
            int idx = -1;

            bool ok = true;
            bool hasPrev = false;
            long prev = 0;
            int trend = 0; // 0 unset, +1 increasing, -1 decreasing (with diff = y - prev)

            long y;
            while (ss >> y)
            {
                ++idx;
                if (idx == skipIdx) continue; // simulate removing this element

                if (hasPrev)
                {
                    long diff = y - prev;
                    long ad   = labs(diff);
                    if (ad < 1 || ad > 3) { ok = false; break; }

                    int sgn = (diff > 0 ? +1 : -1);
                    if (trend == 0) trend = sgn;
                    else if (sgn != trend) { ok = false; break; }
                }

                prev = y;
                hasPrev = true;
            }

            if (ok) {
                lineIsSafe = true; // this skip (or none) makes the report safe
            }
        }

        if (lineIsSafe)
            ++totalSafeRepo;
    }

    cout << totalSafeRepo << "\n";
    return 0; 
}
