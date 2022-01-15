local settings = {
	width = 70,
	borders = {
		horizontal = "─",
		vertical = "│",
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
	},
	line_symbol = "─",
	outer_blank_lines = false,
	inner_blank_lines = false,
}

-- ╭────────────────────────────────────────────────────────────────────╮
-- │                                UTILS                               │
-- ╰────────────────────────────────────────────────────────────────────╯

-- compute padding
local function get_pad(line)
	local pad = (settings.width - string.len(line) - 2) / 2
	local odd
	if string.len(line) % 2 == 0 then
		odd = false
	else
		odd = true
	end
	return pad, odd
end

-- Trim line
local function trim(line, comment_string)
	line = line:gsub(vim.pesc(comment_string), "", 1) -- skip comment string
	line = line:match("^%s*(.-)%s*$") -- remove spaces
	line = line:gsub("\t*(.-)", "", 1) -- remove tabs
	return line
end

-- Return the range of the selected text
local function get_range()
	local line_start_pos, line_end_pos
	local mode = vim.api.nvim_get_mode().mode
	if mode:match("[vV]") then
		line_start_pos = vim.fn.line("v")
		line_end_pos = vim.fn.line(".")
		if line_start_pos > line_end_pos then -- if backward selected
			l = line_end_pos
			line_end_pos = line_start_pos
			line_start_pos = l
		end
	else -- if not in visual mode, return the current line
		line_start_pos = vim.fn.line(".")
		line_end_pos = line_start_pos
	end

	return line_start_pos, line_end_pos
end

-- ╭────────────────────────────────────────────────────────────────────╮
-- │                                CORE                                │
-- ╰────────────────────────────────────────────────────────────────────╯

-- Return the selected text
local function get_text()
	local line_start_pos, line_end_pos = get_range()
	return vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
end

-- Build the box
local function create_box(centered)
	local comment_string = vim.api.nvim_buf_get_option(0, "commentstring")
	comment_string = comment_string:match("^(.*)%%s(.*)")
	local ext_top_row = comment_string
		.. " "
		.. settings.borders.top_left
		.. string.rep(settings.borders.horizontal, settings.width - 2)
		.. settings.borders.top_right
	local ext_bottom_row = comment_string
		.. " "
		.. settings.borders.bottom_left
		.. string.rep(settings.borders.horizontal, settings.width - 2)
		.. settings.borders.bottom_right
	local inner_blank_line = comment_string
		.. " "
		.. settings.borders.vertical
		.. string.rep(" ", settings.width - 2)
		.. settings.borders.vertical
	local int_row = ""
	local lines = {}
	local text = get_text()

	if settings.outer_blank_lines then
		table.insert(lines, "")
	end
	table.insert(lines, ext_top_row)
	if settings.inner_blank_lines then
		table.insert(lines, inner_blank_line)
	end

	if centered then
		for _, line in pairs(text) do
			line = trim(line, comment_string)

			local pad, odd = get_pad(line)
			local parity_pad

			if odd then
				parity_pad = pad + 1
			else
				parity_pad = pad
			end
			int_row = comment_string
				.. " "
				.. settings.borders.vertical
				.. string.rep(" ", parity_pad)
				.. line
				.. string.rep(" ", pad)
				.. settings.borders.vertical
			table.insert(lines, int_row)
		end
	else
		for _, line in pairs(text) do
			line = trim(line, comment_string)

			local pad = settings.width - string.len(line) - 3

			int_row = comment_string
				.. " "
				.. settings.borders.vertical
				.. " "
				.. line
				.. string.rep(" ", pad)
				.. settings.borders.vertical
			table.insert(lines, int_row)
		end
	end

	if settings.inner_blank_lines then
		table.insert(lines, inner_blank_line)
	end
	table.insert(lines, ext_bottom_row)
	if settings.outer_blank_lines then
		table.insert(lines, "")
	end

	return lines
end

local function create_line()
	local comment_string = vim.api.nvim_buf_get_option(0, "commentstring")
	comment_string = comment_string:match("^(.*)%%s(.*)")
	return { comment_string .. " " .. string.rep(settings.line_symbol, settings.width - 2) }
end

-- ╭────────────────────────────────────────────────────────────────────╮
-- │                          PUBLIC FUNCTIONS                          │
-- ╰────────────────────────────────────────────────────────────────────╯

-- Print the box with test left aligned
local function print_lbox()
	local line_start_pos, line_end_pos = get_range()
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box(false))
end

-- Print the box with text centered
local function print_cbox()
	local line_start_pos, line_end_pos = get_range()
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box(true))
end

-- Print a line
local function print_line()
	local line = vim.fn.line(".")
	vim.api.nvim_buf_set_lines(0, line - 1, line, false, create_line())
end

-- Config
local function setup(update)
	settings = vim.tbl_deep_extend("force", settings, update or {})
end

return {
	lbox = print_lbox,
	cbox = print_cbox,
	line = print_line,
	setup = setup,
}
