local settings = {

	width = 80,
	border = {
		horizontal = "─",
		vertical = "│",
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
	},
	outer_blank_lines = false,
	inner_blank_lines = false,
}

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

-- return the range of the selected text
local function get_range()
	local line_start_pos, line_end_pos
	local mode = vim.api.nvim_get_mode()["mode"]
	if mode:match("[vV]") then
		line_start_pos = vim.fn.line("v")
		line_end_pos = vim.fn.line(".")
	else -- if not in visual mode, return the current line
		line_start_pos = vim.fn.line(".")
		line_end_pos = line_start_pos
	end

	return line_start_pos, line_end_pos
end

-- return the selected text
local function get_text()
	local line_start_pos, line_end_pos = get_range()
	return vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
end

-- return the line without the comment string, any leading whitespace and tab
local function trim(line, comment_string)
	line = line:gsub(vim.pesc(comment_string), "", 1)
	line = line:match("^%s*(.-)%s*$")
	line = line:gsub("\t*(.-)", "", 1)
	return line
end

-- Build the box
local function create_box(centered)
	local comment_string = vim.api.nvim_buf_get_option(0, "commentstring")
	comment_string = comment_string:match("^(.*)%%s(.*)")
	local ext_top_row = comment_string
		.. " "
		.. settings.border.top_left
		.. string.rep(settings.border.horizontal, settings.width - 2)
		.. settings.border.top_right
	local ext_bottom_row = comment_string
		.. " "
		.. settings.border.bottom_left
		.. string.rep(settings.border.horizontal, settings.width - 2)
		.. settings.border.bottom_right
	local inner_blank_line = comment_string
		.. " "
		.. settings.border.vertical
		.. string.rep(" ", settings.width - 2)
		.. settings.border.vertical
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
				.. settings.border.vertical
				.. string.rep(" ", parity_pad)
				.. line
				.. string.rep(" ", pad)
				.. settings.border.vertical
			table.insert(lines, int_row)
		end
	else
		for _, line in pairs(text) do
			line = trim(line, comment_string)

			local pad = settings.width - string.len(line) - 3

			int_row = comment_string
				.. " "
				.. settings.border.vertical
				.. " "
				.. line
				.. string.rep(" ", pad)
				.. settings.border.vertical
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

-- print the box with test left aligned
function print_lbox()
	local line_start_pos, line_end_pos = get_range()
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box(false))
end

-- print the box with text centered
function print_cbox()
	local line_start_pos, line_end_pos = get_range()
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box(true))
end

return {
	lbox = print_box,
	cbox = print_cbox,
}
