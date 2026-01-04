// https://adventofcode.com/2024/day/7
// To run it, use the command: node day7_2.js < input.txt

const fs = require("fs");

const input = fs.readFileSync(0, "utf8").trim();
if (!input) {
  console.log("0");
  process.exit(0);
}

// Concatenate two BigInts as digits: a || b
// Implemented as: a * 10^(digits(b)) + b
function concatBigInt(a, b) {
  const digits = b.toString().length;        // b >= 0 in the puzzle input
  const pow10 = 10n ** BigInt(digits);
  return a * pow10 + b;
}

// Backtracking: can we reach target using +, *, || left-to-right?
function canMakeTarget(nums, target, idx, current) {
  if (idx === nums.length) return current === target;

  // Important pruning (works because all operations are monotonic increasing
  // for non-negative integers): if current already exceeds target, no need to continue.
  if (current > target) return false;

  const next = nums[idx];

  // Try +
  if (canMakeTarget(nums, target, idx + 1, current + next)) return true;

  // Try *
  if (canMakeTarget(nums, target, idx + 1, current * next)) return true;

  // Try ||
  if (canMakeTarget(nums, target, idx + 1, concatBigInt(current, next))) return true;

  return false;
}

let sumOfValidTargets = 0n;

for (const line of input.split("\n")) {
  if (!line.trim()) continue;

  const [left, right] = line.split(":");
  if (!right) continue;

  const target = BigInt(left.trim());
  const nums = right.trim().split(/\s+/).map((s) => BigInt(s));

  if (nums.length === 0) continue;

  if (canMakeTarget(nums, target, 1, nums[0])) {
    sumOfValidTargets += target;
  }
}

console.log(sumOfValidTargets.toString());
