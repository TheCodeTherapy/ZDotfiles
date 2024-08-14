-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

require("thecodetherapy.goto")

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local surround_chars = "[\"'(){}%[%]]"

local function jump_right_on_surroundings()
  local bufnr = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_get_current_win()
  local cursor_pos = vim.api.nvim_win_get_cursor(winnr)
  local line_num, col = cursor_pos[1], cursor_pos[2] + 1
  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  for l = line_num, total_lines do
    local line_text = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1]
    local start_index = l == line_num and col or 1
    local found_at_line_end = false
    for i = start_index, #line_text do
      if string.match(line_text:sub(i, i), surround_chars) then
        if i == #line_text then
          found_at_line_end = true
          break
        else
          vim.api.nvim_win_set_cursor(winnr, { l, i })
          return
        end
      end
    end

    if found_at_line_end then
      if l < total_lines then
        line_num = l + 1
        col = 1
      else
        return
      end
    else
      if l < total_lines then
        line_num = l + 1
        col = 1
      end
    end
  end
end

local function jump_left_on_surroundings()
  local bufnr = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_get_current_win()
  local cursor_pos = vim.api.nvim_win_get_cursor(winnr)
  local line_num, col = cursor_pos[1], cursor_pos[2]
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_num, false)

  for ln = #lines, 1, -1 do
    local line_text = lines[ln]
    local end_col = ln == line_num and col or #line_text
    for i = end_col, 1, -1 do
      local char = line_text:sub(i, i)
      if string.match(char, surround_chars) then
        vim.api.nvim_win_set_cursor(winnr, { ln, i - 2 })
        return
      end
    end
  end
end

local function copy_diagnostics_to_clipboard()
  local diagnostics = vim.diagnostic.get(0)
  local lines = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(lines, diag.message)
  end
  local text = table.concat(lines, "\n")
  vim.fn.setreg("+", text)
  print("Diagnostics copied to clipboard!")
end

local function copy_file_and_diagnostics_to_clipboard()
  local file_path = vim.fn.expand("%")
  local relative_file_path = vim.fn.fnamemodify(file_path, ":~:.")
  local file_extension = vim.fn.fnamemodify(file_path, ":e")
  local markdown_code_block_identifier = file_extension
  local extension_to_markdown = {
    ts = "typescript",
    js = "javascript",
    py = "python",
  }
  if extension_to_markdown[file_extension] then
    markdown_code_block_identifier = extension_to_markdown[file_extension]
  end
  local file_content = table.concat(vim.fn.readfile(file_path), "\n")
  local diagnostics = vim.diagnostic.get(0)
  local diagnostic_lines = {}
  for _, diag in ipairs(diagnostics) do
    local line_content = vim.fn.getline(diag.lnum + 1)
    table.insert(
      diagnostic_lines,
      string.format("\n\n>- Line %d: `%s`\n>- Diagnostic: %s\n", diag.lnum + 1, line_content, diag.message)
    )
  end
  local diagnostics_text = table.concat(diagnostic_lines, "\n\n")
  local clipboard_text = string.format(
    "File: %s\n\n```%s\n%s\n```\n\nDiagnostics:\n%s",
    relative_file_path,
    markdown_code_block_identifier,
    file_content,
    diagnostics_text
  )
  vim.fn.setreg("+", clipboard_text)
  print("File and diagnostics copied to clipboard!")
end

local function create_and_preview_diagnostics()
  copy_file_and_diagnostics_to_clipboard()
  local diagnostics_file_path = vim.fn.getcwd() .. "/diagnostics.md"
  vim.cmd("e " .. diagnostics_file_path)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  vim.cmd("write")
  vim.cmd("MarkdownPreview")
end

keymap.set("n", "<leader>ccm", create_and_preview_diagnostics, opts)
keymap.set("n", "<leader>cca", copy_file_and_diagnostics_to_clipboard, opts)
keymap.set("n", "<leader>cc", copy_diagnostics_to_clipboard, opts)

keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", "vb_d")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Move lines around
keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)
keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)

-- New tab
keymap.set("n", "te", "tabedit", opts)
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Morse surroundings
keymap.set({ "n", "i", "v" }, ",,,", jump_left_on_surroundings, opts)
keymap.set({ "n", "i", "v" }, ",,", jump_right_on_surroundings, opts)

-- Move around
keymap.set("n", "<leader><Left>", "<C-w>h")
keymap.set("n", "<leader><Right>", "<C-w>l")
keymap.set("n", "<leader><Up>", "<C-w>k")
keymap.set("n", "<leader><Down>", "<C-w>j")
keymap.set("n", "<A-Right>", ":BufferLineCycleNext<CR>", opts)
keymap.set("n", "<A-Left>", ":BufferLineCyclePrev<CR>", opts)

-- Resize
keymap.set("n", "<C-w><Left>", "<C-w><")
keymap.set("n", "<C-w><Right>", "<C-w>>")

-- Disable default macro record
keymap.set("n", "q", "<Nop>", opts)

-- Normie emulation
keymap.set("n", "<S-End>", "v$")
keymap.set("v", "<S-End>", "g_", opts)
keymap.set("v", "<C-c>", '"+y', opts)
keymap.set("n", "<C-v>", '"+p', opts)
keymap.set("i", "<C-v>", "<C-r>+", { noremap = true })

local signature_help_window_opened = false
local signature_help_forced = false

local function my_signature_help_handler(handler)
  return function(...)
    if signature_help_forced and signature_help_window_opened then
      signature_help_forced = false
      return handler(...)
    end
    if signature_help_window_opened then
      return
    end
    local fbuf, fwin = handler(...)
    signature_help_window_opened = true
    vim.api.nvim_exec("autocmd WinClosed " .. fwin .. " lua signature_help_window_opened=false", false)
    return fbuf, fwin
  end
end

---@diagnostic disable-next-line: unused-local, unused-function
local function force_signature_help()
  signature_help_forced = true
  vim.lsp.buf.signature_help()
end

-- These mappings allow to focus on the floating window when opened.
keymap.set("n", "<C-k>", force_signature_help, opts)
keymap.set("i", "<C-k>", force_signature_help, opts)

vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(my_signature_help_handler(vim.lsp.handlers.signature_help), {})

vim.api.nvim_set_keymap("n", "gg", "<cmd>lua require('thecodetherapy.goto').go_to_implementation()<CR>", opts)
