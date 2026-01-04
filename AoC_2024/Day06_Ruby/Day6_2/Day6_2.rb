# https://adventofcode.com/2024/day/6
# To run it: ruby Day6_2.rb

grid = File.read("input.txt").lines.map(&:chomp).map(&:chars)
h = grid.length
w = grid[0].length

# Find start '^'
sx = sy = nil
grid.each_with_index do |row, y|
  row.each_with_index do |c, x|
    if c == '^'
      sx = x
      sy = y
      break
    end
  end
  break if sx
end

raise "No '^' found in input.txt (wrong file?)" if sx.nil?

# Directions: 0=up, 1=right, 2=down, 3=left
DX = [0, 1, 0, -1]
DY = [-1, 0, 1, 0]

def inside?(x, y, w, h)
  x >= 0 && x < w && y >= 0 && y < h
end

def run_part1_path(grid, sx, sy, w, h)
  x = sx
  y = sy
  dir = 0
  visited = {}
  visited[[x, y]] = true

  loop do
    nx = x + DX[dir]
    ny = y + DY[dir]

    break unless inside?(nx, ny, w, h)

    if grid[ny][nx] == '#'
      dir = (dir + 1) % 4
    else
      x = nx
      y = ny
      visited[[x, y]] = true
    end
  end

  visited
end

def loops_with_obstruction?(grid, sx, sy, w, h, ox, oy)
  x = sx
  y = sy
  dir = 0

  seen_states = {}
  seen_states[[x, y, dir]] = true

  loop do
    nx = x + DX[dir]
    ny = y + DY[dir]

    return false unless inside?(nx, ny, w, h)

    blocked = (grid[ny][nx] == '#') || (nx == ox && ny == oy)

    if blocked
      dir = (dir + 1) % 4
    else
      x = nx
      y = ny
    end

    state = [x, y, dir]
    return true if seen_states[state]
    seen_states[state] = true
  end
end

# 1) normal path from Part 1
path = run_part1_path(grid, sx, sy, w, h)

# 2) candidates from visited cells (excluding start), only '.'
candidates = path.keys.select do |(x, y)|
  next false if x == sx && y == sy
  grid[y][x] == '.'
end

# 3) test each candidate with progress
count = 0
total = candidates.size
start_time = Time.now
step = [total / 100, 1].max

candidates.each_with_index do |(ox, oy), i|
  if i % step == 0 || i + 1 == total
    elapsed = Time.now - start_time
    percent = (i + 1) * 100.0 / total
    eta = elapsed * (total - i - 1) / (i + 1)
    print "\r%6.0f%%  Elapsed: %5.0fs  ETA: %5.0fs" % [percent, elapsed, eta]
  end

  count += 1 if loops_with_obstruction?(grid, sx, sy, w, h, ox, oy)
end

puts count
