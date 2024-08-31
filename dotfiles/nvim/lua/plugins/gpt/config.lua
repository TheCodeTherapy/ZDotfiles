local chatgpt = require("plugins.gpt.chatgpt")

-- Function to create and handle a multi-line input floating window
local function get_user_input(prompt_text, callback)
  -- Create a new buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile" -- Set buffer type to nofile instead of prompt
  -- Define the window border and position
  local width = math.floor(vim.o.columns * 0.5)
  local height = 5
  local opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set a prompt in the window
  vim.fn.prompt_setprompt(buf, prompt_text .. "\n")

  -- Function to close the window and return the input
  local function close_window_and_return_input()
    local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")

    -- Clean the input by removing null characters or any unexpected characters
    input = input:gsub("%z", "") -- Removes any null characters
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })

    if callback then
      callback(input)
    end
  end

  -- Configure key mappings for the buffer
  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = close_window_and_return_input,
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = close_window_and_return_input,
  })

  vim.opt_local.wrap = true

  -- Start insert mode in the floating window
  vim.cmd("startinsert")
end

-- Command to trigger the GPT request with the multi-line input window
vim.api.nvim_create_user_command("GPT", function()
  local api_key = os.getenv("OPENAI_API_KEY")
  if not api_key then
    print("Error: OPENAI_API_KEY is not set.")
    return
  end

  get_user_input("User Prompt:", function(user_input)
    if user_input and user_input:gsub("%s+", "") ~= "" then
      chatgpt.chatgpt_request(
        api_key,
        "You are a helpful assistant. Always answer in a markdown format. When writing code, please keep in mind to properly set the markdown for the appropriate syntax highlight.",
        user_input,
        "gpt_response.md"
      )
      vim.cmd("e gpt_response.md")
    else
      print("Input was canceled or empty")
    end
  end)
end, {})

return {}
