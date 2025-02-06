local maze = {}
local uv = vim.loop

local MAP_WIDTH, MAP_HEIGHT = 30, 30
local anticipation_distance = 6.0
local speed = 0.1
local ROTATION_STEPS = 10
local ROTATION_INCREMENT = (math.pi / 2) / ROTATION_STEPS

local playerX, playerY = 3.0, 3.0
local dirX, dirY = 1.0, 0.0
local angle, rotating, rotationProgress = 0.0, 0, 0
local last_rotation = 0
local worldMap = {}

local ns = vim.api.nvim_create_namespace("screensaver-maze")
local timer
local fake_buf
local extmark_id = nil

local function split_string(input)
  local t = {}
  for c in input:gmatch(".") do
    table.insert(t, c)
  end
  return t
end

local shading_string = ".-':_,^=;><+!rc*/z?sLTv)J7(|Fi{C}fI31tlu[neoZ5Yxjya]2ESwqkP6h9d4VpOGbUAKXHm8RD#$Bg0MNWQ%&@"
local shading_chars = split_string(shading_string)

local function is_wall(x, y)
  local mapX, mapY = math.floor(x), math.floor(y)
  return worldMap[mapY] and worldMap[mapY][mapX] == "1"
end

local function generate_maze()
  worldMap = {}

  -- Initialize maze with walls
  for y = 1, MAP_HEIGHT do
    worldMap[y] = {}
    for x = 1, MAP_WIDTH do
      worldMap[y][x] = "1" -- Fill with walls
    end
  end

  -- Define maze carving function using Recursive Backtracking
  local function carve_maze(x, y)
    worldMap[y][x] = "0" -- Open the path

    local directions = {
      { x = 0, y = -2 },
      { x = 0, y = 2 },
      { x = -2, y = 0 },
      { x = 2, y = 0 },
    }

    -- Shuffle directions
    for i = #directions, 2, -1 do
      local j = math.random(i)
      directions[i], directions[j] = directions[j], directions[i]
    end

    for _, dir in ipairs(directions) do
      local nx, ny = x + dir.x, y + dir.y
      if nx > 1 and ny > 1 and nx < MAP_WIDTH and ny < MAP_HEIGHT and worldMap[ny][nx] == "1" then
        worldMap[ny - dir.y / 2][nx - dir.x / 2] = "0" -- Break wall between cells
        carve_maze(nx, ny)
      end
    end
  end

  -- Ensure outer walls
  for x = 1, MAP_WIDTH do
    worldMap[1][x], worldMap[MAP_HEIGHT][x] = "1", "1"
  end

  for y = 1, MAP_HEIGHT do
    worldMap[y][1], worldMap[y][MAP_WIDTH] = "1", "1"
  end

  -- Generate the maze starting from (3,3)
  carve_maze(3, 3)

  -- Set player start position
  repeat
    playerX, playerY = 3 + math.random(MAP_WIDTH - 6), 3 + math.random(MAP_HEIGHT - 6)
  until not is_wall(playerX, playerY)
end

local function rotate_player()
  if rotating ~= 0 then
    angle = angle + rotating * ROTATION_INCREMENT
    dirX, dirY = math.cos(angle), math.sin(angle)
    rotationProgress = rotationProgress + 1

    if rotationProgress >= ROTATION_STEPS then
      last_rotation = rotating -- Store last rotation
      rotating, rotationProgress = 0, 0
    end
  end
end

local function get_valid_rotations()
  local possible_rotations = {}

  -- Try turning right
  local right_angle = angle + (math.pi / 2)
  local right_dirX, right_dirY = math.cos(right_angle), math.sin(right_angle)
  if not is_wall(playerX + right_dirX, playerY + right_dirY) then
    table.insert(possible_rotations, 1)
  end

  -- Try turning left
  local left_angle = angle - (math.pi / 2)
  local left_dirX, left_dirY = math.cos(left_angle), math.sin(left_angle)
  if not is_wall(playerX + left_dirX, playerY + left_dirY) then
    table.insert(possible_rotations, -1)
  end

  return possible_rotations
end

local function update_movement()
  if rotating ~= 0 then
    rotate_player()
    return
  end

  local futureX = playerX + dirX * anticipation_distance * speed
  local futureY = playerY + dirY * anticipation_distance * speed

  if is_wall(futureX, futureY) then
    local possible_rotations = get_valid_rotations()

    -- Remove immediate reversal from options
    for i = #possible_rotations, 1, -1 do
      if possible_rotations[i] == -last_rotation then
        table.remove(possible_rotations, i)
      end
    end

    if #possible_rotations > 0 then
      rotating = possible_rotations[math.random(#possible_rotations)] -- Pick a valid rotation
    else
      rotating = -last_rotation -- If no valid turns, force a reversal
    end
  else
    playerX = playerX + dirX * speed
    playerY = playerY + dirY * speed
  end
end
local function render()
  local screenHeight = vim.o.lines
  local screenWidth = vim.o.columns

  local grid = {}
  for y = 1, screenHeight do
    grid[y] = {}
    for x = 1, screenWidth do
      grid[y][x] = { " ", "Black" }
    end
  end

  local FOV = math.pi / 2
  local projection_height = screenHeight / 2

  for x = 1, screenWidth do
    local cameraX = (2.0 * x / screenWidth - 1.0) * math.tan(FOV / 2)
    local rayDirX, rayDirY = dirX + cameraX * -dirY, dirY + cameraX * dirX

    local mapX, mapY = math.floor(playerX), math.floor(playerY)
    local deltaDistX = (rayDirX == 0) and 1e30 or math.abs(1 / rayDirX)
    local deltaDistY = (rayDirY == 0) and 1e30 or math.abs(1 / rayDirY)

    local stepX, stepY = (rayDirX < 0) and -1 or 1, (rayDirY < 0) and -1 or 1
    local sideDistX = (rayDirX < 0) and (playerX - mapX) * deltaDistX or (mapX + 1 - playerX) * deltaDistX
    local sideDistY = (rayDirY < 0) and (playerY - mapY) * deltaDistY or (mapY + 1 - playerY) * deltaDistY

    local hit, side = false, 0
    while not hit do
      if mapX < 1 or mapX > MAP_WIDTH or mapY < 1 or mapY > MAP_HEIGHT then
        break
      end
      if sideDistX < sideDistY then
        sideDistX, mapX, side = sideDistX + deltaDistX, mapX + stepX, 0
      else
        sideDistY, mapY, side = sideDistY + deltaDistY, mapY + stepY, 1
      end
      if worldMap[mapY] and worldMap[mapY][mapX] == "1" then
        hit = true
      end
    end

    local perpWallDist = (side == 0) and (mapX - playerX + (1 - stepX) / 2) / rayDirX
      or (mapY - playerY + (1 - stepY) / 2) / rayDirY

    local lineHeight = math.floor(projection_height / perpWallDist)
    local shadeIndex = math.max(1, math.min(#shading_chars, math.floor(lineHeight / screenHeight * #shading_chars)))
    local shadeChar = shading_chars[shadeIndex]

    for y = 1, screenHeight do
      grid[y][x] = {
        (y >= screenHeight / 2 - lineHeight / 2 and y <= screenHeight / 2 + lineHeight / 2) and shadeChar or " ",
        "White",
      }
    end
  end

  extmark_id = vim.api.nvim_buf_set_extmark(fake_buf, ns, 0, 0, { virt_lines = grid, id = extmark_id })
end

function maze.start(buf, config)
  fake_buf = buf
  generate_maze()
  ---@diagnostic disable-next-line: undefined-field
  timer = uv.new_timer()
  timer:start(
    10,
    config.tick_time,
    vim.schedule_wrap(function()
      update_movement()
      render()
    end)
  )
end

function maze.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

return maze
