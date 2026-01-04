#https://adventofcode.com/2024/day/6
#To run it, use the command: ruby Day6_1.rb 

grid = File.read("input.txt").lines.map(&:chomp).map(&:chars)

height = grid.length
width  = grid[0].length

# Find the starting position (the '^' character)
start_x = start_y = nil
grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    if cell == '^'
      start_x = x
      start_y = y
      break
    end
  end
  break if start_x
end

# Directions encoded as 0=up, 1=right, 2=down, 3=left
dir = 0

# Movement vectors for each direction
dx = [0, 1, 0, -1]
dy = [-1, 0, 1, 0]

# Track visited positions using a Hash as a set
visited = {}
x = start_x
y = start_y
visited[[x, y]] = true

loop do
  nx = x + dx[dir]
  ny = y + dy[dir]

  # If the guard would step outside the grid, we're done
  if nx < 0 || nx >= width || ny < 0 || ny >= height
    break
  end

  # If there's an obstacle ahead, turn right
  if grid[ny][nx] == '#'
    dir = (dir + 1) % 4
  else
    # Otherwise move forward and mark visited
    x = nx
    y = ny
    visited[[x, y]] = true
  end
end

puts visited.size
