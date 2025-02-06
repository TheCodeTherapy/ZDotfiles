local screensaver = {}
local timer, is_running, fake_buf, fake_win
local uv = vim.loop

local effects = {
  matrix = require("config.ss_matrix"),
  maze = require("config.ss_maze"),
}

local default_opts = {
  style = "maze", -- "matrix" or "maze"
  customcmd = "",
  after = 300,
  offset = 0,
  exclude_filetypes = {
    "TelescopePrompt",
    "NvimTree",
    "dashboard",
    "lir",
    "neo-tree",
    "help",
  },
  exclude_buftypes = { "terminal" },
  matrix = {
    tick_time = 50,
    headache = false,
  },
  maze = {
    tick_time = 50,
  },
}

local opts = default_opts
local old_guicursor, old_cursorline, old_cursorcolumn

---@return integer buf The buffer ID
---@return integer win The window ID
local function create_floating_window()
  local w = vim.opt.numberwidth:get() + vim.opt.foldcolumn:get() + 2

  ---@type vim.api.keyset.win_config
  local win_opts = {
    relative = "win",
    width = vim.o.columns - w,
    height = vim.o.lines - vim.opt.cmdheight:get() - 2,
    border = "none",
    row = 0,
    col = w,
    style = "minimal",
  }

  fake_buf = vim.api.nvim_create_buf(false, true)
  fake_win = vim.api.nvim_open_win(fake_buf, false, win_opts)

  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(fake_win) then
      vim.api.nvim_set_option_value("cursorline", false, { win = fake_win })
      vim.api.nvim_set_option_value("cursorcolumn", false, { win = fake_win })
      vim.api.nvim_set_option_value(
        "winhl",
        "Normal:Normal,CursorLine:Normal,CursorColumn:Normal,Cursor:Normal",
        { win = fake_win }
      )
    end
  end, 100)

  return fake_buf, fake_win
end

local function hide_cursor()
  old_guicursor = vim.o.guicursor
  old_cursorline = vim.o.cursorline
  old_cursorcolumn = vim.o.cursorcolumn
  vim.opt.guicursor = "a:Cursor/lCursor"
  vim.opt.cursorline = false
  vim.opt.cursorcolumn = false
  vim.cmd([[ autocmd CursorMoved,CursorMovedI * set guicursor=a:Cursor/lCursor ]])
end

local function show_cursor()
  vim.opt.guicursor = old_guicursor
  vim.opt.cursorline = old_cursorline
  vim.opt.cursorcolumn = old_cursorcolumn
  vim.cmd([[ autocmd! CursorMoved,CursorMovedI ]])
end

local function start_screensaver()
  if is_running then
    return
  end

  is_running = true
  hide_cursor()

  if pcall(require, "zen-mode") and vim.fn.exists(":ZenMode") == 2 then
    require("zen-mode").toggle(true)
  end

  fake_buf, fake_win = create_floating_window()

  local style = opts.style or "matrix"
  if effects[style] then
    effects[style].start(fake_buf, opts[style]) -- Pass correct effect config
  elseif style == "customcmd" then
    vim.cmd(opts.customcmd)
  end
end

local function stop_screensaver()
  if is_running then
    is_running = false
    local style = opts.style or "matrix"
    if effects[style] then
      effects[style].stop()
    end
  end

  show_cursor()

  if fake_win and vim.api.nvim_win_is_valid(fake_win) then
    vim.api.nvim_win_close(fake_win, true)
  end

  if fake_buf and vim.api.nvim_buf_is_valid(fake_buf) then
    vim.api.nvim_buf_delete(fake_buf, { force = true })
  end
end

local function reset_activity()
  if timer then
    if timer:is_active() then
      timer:stop()
    end
    if not timer:is_closing() then
      timer:close()
    end
  end

  stop_screensaver()

  ---@diagnostic disable-next-line: undefined-field
  timer = uv.new_timer()
  timer:start(opts.after * 1000, 0, vim.schedule_wrap(start_screensaver))
end

function screensaver.start_now()
  stop_screensaver() -- Ensure it's not already running
  start_screensaver()
end

function screensaver.setup(user_opts)
  opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})

  local grp = vim.api.nvim_create_augroup("screensaver", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "TextChanged" }, {
    group = grp,
    callback = reset_activity,
  })

  vim.keymap.set(
    "n",
    "<leader>rm",
    screensaver.start_now,
    { noremap = true, silent = true, desc = "Start Screensaver" }
  )
end
return screensaver
