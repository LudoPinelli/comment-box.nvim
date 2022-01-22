local buf, win

local function open_win()
	buf = vim.api.nvim_create_buf(false, true)

	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

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

	win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(win, "cursorline", true)
end

local function view()
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	local cat_path = vim.api.nvim_get_runtime_file("catalog/catalog.txt", false)[1]
	vim.api.nvim_command("$read" .. cat_path)
	vim.api.nvim_buf_set_option(0, "modifiable", false)
end

local function close()
	vim.api.nvim_win_close(win, true)
end

local function keymap()
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		"<Cmd>lua require('comment-box.catalog_view').close()<CR>",
		{ noremap = true, silent = true }
	)
end

local function view_cat()
	open_win()
	keymap()
	view()
end

return {
	view_cat = view_cat,
	close = close,
}
