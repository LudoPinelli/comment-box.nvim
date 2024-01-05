--          ╭─────────────────────────────────────────────────────────╮
--          │                      CATALOG VIEW                       │
--          ╰─────────────────────────────────────────────────────────╯

---@type number, number
local buf, win
local api = vim.api

local function open_win()
  buf = api.nvim_create_buf(false, true)

  api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

  local width = api.nvim_get_option_value("columns", {})
  local height = api.nvim_get_option_value("lines", {})

  local win_width = 47
  local win_height = math.ceil(height * 0.9 - 4)

  local row = math.ceil((height - win_height) / 2 - 1)
  local col = width - 1

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    anchor = "NE",
    border = "rounded",
  }

  win = api.nvim_open_win(buf, true, opts)
  api.nvim_set_option_value("cursorline", true, { win = win })
end

local function view()
  api.nvim_set_option_value("modifiable", true, { buf = buf })
  local cat_path = api.nvim_get_runtime_file("catalog/catalog.txt", false)[1]
  api.nvim_command("$read " .. cat_path)
  api.nvim_set_option_value("modifiable", false, { buf = 0 })
end

local function keymap()
  api.nvim_buf_set_keymap(
    buf,
    "n",
    "q",
    "<Cmd>lua require('comment-box.catalog_view').close()<CR>",
    { noremap = true, silent = true }
  )
end

return {
  view_cat = function()
    open_win()
    keymap()
    view()
  end,
  close = function()
    api.nvim_win_close(win, true)
  end,
}
