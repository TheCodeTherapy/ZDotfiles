math.randomseed(os.time())

local MAP_WIDTH, MAP_HEIGHT = 72, 72
local CELL_SIZE = 6 -- Minimum spacing between paths
local CORRIDOR_WIDTH = 3 -- Make sure every path is at least 3x3 wide
local maze = {}

-- Directions for movement (Up, Down, Left, Right)
local directions = {
	{ x = 0, y = -1 },
	{ x = 0, y = 1 },
	{ x = -1, y = 0 },
	{ x = 1, y = 0 },
}

-- Initialize the grid with walls
local function initialize_maze()
	for y = 1, MAP_HEIGHT do
		maze[y] = {}
		for x = 1, MAP_WIDTH do
			maze[y][x] = "#" -- Walls everywhere initially
		end
	end
end

-- Check if a cell is within bounds
local function is_within_bounds(x, y)
	return x > 1 and x < MAP_WIDTH and y > 1 and y < MAP_HEIGHT
end

-- Carve out a wide corridor in both the movement direction and perpendicular to it
local function carve_wide_corridor(x, y, dir)
	-- Open a straight path in the movement direction
	for i = 0, CELL_SIZE - 1 do
		if is_within_bounds(x + dir.x * i, y + dir.y * i) then
			maze[y + dir.y * i][x + dir.x * i] = " "
		end
	end

	-- Ensure width in the perpendicular direction
	if dir.x ~= 0 then
		-- Moving horizontally, widen the corridor vertically
		for dy = -math.floor(CORRIDOR_WIDTH / 2), math.floor(CORRIDOR_WIDTH / 2) do
			for i = 0, CELL_SIZE - 1 do
				if is_within_bounds(x + dir.x * i, y + dy) then
					maze[y + dy][x + dir.x * i] = " "
				end
			end
		end
	else
		-- Moving vertically, widen the corridor horizontally
		for dx = -math.floor(CORRIDOR_WIDTH / 2), math.floor(CORRIDOR_WIDTH / 2) do
			for i = 0, CELL_SIZE - 1 do
				if is_within_bounds(x + dx, y + dir.y * i) then
					maze[y + dir.y * i][x + dx] = " "
				end
			end
		end
	end
end

-- Recursive Backtracking Maze Generation
local function carve_maze(x, y)
	maze[y][x] = " " -- Mark cell as open space

	-- Shuffle directions to ensure randomness
	local shuffled_dirs = {}
	for i, v in ipairs(directions) do
		table.insert(shuffled_dirs, v)
	end
	for i = #shuffled_dirs, 2, -1 do
		local j = math.random(i)
		shuffled_dirs[i], shuffled_dirs[j] = shuffled_dirs[j], shuffled_dirs[i]
	end

	for _, dir in ipairs(shuffled_dirs) do
		local nx, ny = x + dir.x * CELL_SIZE, y + dir.y * CELL_SIZE
		if is_within_bounds(nx, ny) and maze[ny][nx] == "#" then
			-- Carve out the passage with width
			carve_wide_corridor(x, y, dir)
			carve_maze(nx, ny)
		end
	end
end

-- Generate the maze
local function generate_maze()
	initialize_maze()
	local start_x, start_y = 3, 3 -- Start point
	carve_maze(start_x, start_y)

	-- Ensure outer walls
	for x = 1, MAP_WIDTH do
		maze[1][x], maze[MAP_HEIGHT][x] = "#", "#"
	end
	for y = 1, MAP_HEIGHT do
		maze[y][1], maze[y][MAP_WIDTH] = "#", "#"
	end
end

-- Print the maze to terminal
local function print_maze()
	for y = 1, MAP_HEIGHT do
		for x = 1, MAP_WIDTH do
			io.write(maze[y][x])
		end
		io.write("\n")
	end
end

-- Run it
generate_maze()
print_maze()
