/*
https://adventofcode.com/2024/day/2
To compile and run:
g++ Day2_1.cpp -o Day2_1
./Day2_1
*/

#include <iostream>   // for console input/output (cout, cerr)
#include <fstream>    // for file input/output (ifstream)
#include <sstream>    // for reading data from a line (stringstream)
#include <string>     // for using std::string
#include <cmath>      // for abs() function
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
        // Skip empty lines (if any)
        if (line.empty())
            continue;

        // Create a stringstream to read numbers from this line
        stringstream ss(line);

        long prev, x;        // prev = previous number, x = current number
        bool hasPrev = false; // tracks if a previous number exists
        int trend = 0;        // 0 = undefined, +1 = increasing, -1 = decreasing
        bool safe = true;     // flag to mark if the current line is "safe"

        // Read each number from the line until end of line or until unsafe
        while ((ss >> x) && (safe == true))
        {
            // Compare only if we already have a previous value
            if (hasPrev)
            {
                int diff = prev - x;  // difference between consecutive numbers

                // If difference is too small (<1) or too large (>3), unsafe
                if ((abs(diff) < 1) || (abs(diff) > 3))
                {
                    safe = false;
                    break; // stop checking this line
                }

                // Determine the direction (sign) of the difference
                int sgn = (diff > 0) ? 1 : -1; // +1 = decreasing, -1 = increasing

                // If no previous trend is set, establish the initial trend
                if (trend == 0)
                    trend = sgn;

                // If the trend changes (e.g. from increasing to decreasing), unsafe
                else if (sgn != trend)
                {
                    safe = false;
                    break;
                }
            }

            // Store the current value as the previous for the next iteration
            prev = x;
            hasPrev = true;
        }

        // If the report (line) is still marked as safe, count it
        if (safe)
            ++totalSafeRepo;
    }

    // Output the total number of safe reports
    cout << totalSafeRepo << "\n";

    return 0; 
}
