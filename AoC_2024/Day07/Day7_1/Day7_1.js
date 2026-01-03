// https://adventofcode.com/2024/day/7
// To run it, use the command: node day7_1.js < input.txt

const fs = require("fs");

// Read all input from stdin, trim trailing whitespace
const input = fs.readFileSync(0, "utf8").trim();
if (!input) {
  console.log(0);
  process.exit(0);
}

let sumOfValidTargets = 0;

// Try recursively placing operators between numbers
function canMakeTarget(nums, target, idx, current) {
  // If we ran out of nums, check if we hit the target
  if (idx === nums.length) {
    return current === target;
  }
  const next = nums[idx];

  // Try adding
  if (canMakeTarget(nums, target, idx + 1, current + next)) {
    return true;
  }
  // Try multiplying
  if (canMakeTarget(nums, target, idx + 1, current * next)) {
    return true;
  }
  return false;
}

for (const line of input.split("\n")) {
  // Parse "target: a b c ..."
  const [left, right] = line.split(":");
  if (!right) continue;

  const target = Number(left.trim());
  const parts = right.trim().split(/\s+/).map(Number);

  // If no parts, skip
  if (parts.length === 0) continue;

  // Perform recursive check:
  // first number is the base
  if (canMakeTarget(parts, target, 1, parts[0])) {
    sumOfValidTargets += target;
  }
}

console.log(sumOfValidTargets);
