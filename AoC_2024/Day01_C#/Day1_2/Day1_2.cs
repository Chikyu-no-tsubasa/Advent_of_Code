/*
https://adventofcode.com/2024/day/1
To run it, use the command: dotnet script Day1_2.cs 
 */

// Lists to store the first and second column values
List<int> left = new List<int>();
List<int> right = new List<int>();

// File name (adjust the path if necessary)
string filePath = "input.txt";
// Variable to hold the similarity score
int similarityScore = 0;

// Open the file using a StreamReader
using (StreamReader reader = new StreamReader(filePath))
{
    string line;

    // Read the file line by line until the end
    while ((line = reader.ReadLine()) != null)
    {
        // Skip empty or whitespace-only lines
        if (string.IsNullOrWhiteSpace(line))
            continue;

        // Split the line by spaces or tabs, ignoring multiple spaces
        string[] parts = line.Split(
            new char[] { ' ', '\t' },
            StringSplitOptions.RemoveEmptyEntries
        );

        // Ensure there are at least two elements per line
        if (parts.Length < 2)
        {
            Console.WriteLine($"Skipped line (not enough elements): \"{line}\"");
            continue;
        }

        // // Convert the first two parts to integers
        int a = int.Parse(parts[0]);
        int b = int.Parse(parts[1]);

        // // Add them to the respective lists
        left.Add(a);
        right.Add(b);

    }
}

// Sort both lists
left.Sort();
right.Sort();

// Calculate similarity score
for (int i = 0; i < left.Count; i++)
{
    int simCount = 0;
    for (int j = 0; j < right.Count; j++)
    {
        if (left[i] == right[j])
            simCount++;
    }
    similarityScore += (simCount * left[i]);
}

Console.WriteLine(similarityScore);
