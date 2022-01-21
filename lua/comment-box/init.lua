local settings = {
	width = 70,
	borders = {
		horizontal = "─",
		vertical = "│",
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
		horizontal_bottom = "─",
		vertical_right = "│",
	},
	line = {
		line = "─",
		line_start = "─",
		line_end = "─",
	},
	outer_blank_lines = false,
	inner_blank_lines = false,
}

local width = settings.width - 4

-- ╭────────────────────────────────────────────────────────────────────╮
-- │                                UTILS                               │
-- ╰────────────────────────────────────────────────────────────────────╯

-- Compute padding
local function get_pad(line)
	local pad = (settings.width - vim.fn.strdisplaywidth(line) - 2) / 2
	local odd

	if vim.fn.strdisplaywidth(line) % 2 == 0 then
		odd = false
	else
		odd = true
	end
	return pad, odd
end

-- Return the range of the selected text
local function get_range()
	local line_start_pos, line_end_pos
	local mode = vim.api.nvim_get_mode().mode

	if mode:match("[vV]") then
		line_start_pos = vim.fn.line("v")
		line_end_pos = vim.fn.line(".")
		if line_start_pos > line_end_pos then -- if backward selected
			line_start_pos, line_end_pos = line_end_pos, line_start_pos
		end
	else -- if not in visual mode, return the current line
		line_start_pos = vim.fn.line(".")
		line_end_pos = line_start_pos
	end

	return line_start_pos, line_end_pos
end

-- Return the correct cursor position after a box has been created
function set_cur_pos(end_pos)
	local cur_pos = end_pos + 2

	if settings.inner_blank_lines then
		cur_pos = cur_pos + 2
	end
	if settings.outer_blank_lines then
		cur_pos = cur_pos + 2
	end
	return cur_pos
end

-- Skip comment string if there is one at the beginning of the line trop longue
local function skip_cs(line, comment_string, centered)
	local trimmed_line = vim.trim(line)
	local cs_len = vim.fn.strdisplaywidth(comment_string)

	if trimmed_line:sub(1, cs_len) == comment_string then
		line = line:gsub(vim.pesc(comment_string), "", 1)
	end
	if not centered then
		return line
	else -- if centered need to trim for correct padding
		return vim.trim(line)
	end
end

-- Wrap lines
local function wrap(text)
	local str_tab = {}
	local str = text:sub(1, width)
	local rstr = str:reverse()
	local f = rstr:find(" ")

	f = width - f
	table.insert(str_tab, string.sub(text, 1, f))
	table.insert(str_tab, string.sub(text, f + 1))
	return str_tab
end

-- Prepare each line and rewrote the table in case of wraping lines
local function format_lines(text, comment_string, centered)
	for pos, str in ipairs(text) do
		table.remove(text, pos)
		str = skip_cs(str, comment_string, centered)
		table.insert(text, pos, str)
		if vim.fn.strdisplaywidth(str) > width then
			to_insert = wrap(str)
			for ipos, st in ipairs(to_insert) do
				table.insert(text, pos + ipos, st)
			end
			table.remove(text, pos)
		end
	end
	return text
end

local function set_borders(choice)
	choice = choice or 0
	local borders
	if choice == 0 then
		borders = settings.borders
	else
		local cat = require("comment-box.catalog")
		borders = cat.boxes[choice] or settings.borders
	end
	return borders
end

local function set_line(choice)
	choice = choice or 0
	local symbols
	if choice == 0 then
		symbols = settings.line
	else
		local cat = require("comment-box.catalog")
		symbols = cat.lines[choice] or settings.lines
	end
	return symbols
end

-- ╭────────────────────────────────────────────────────────────────────╮
-- │                                CORE                                │
-- ╰────────────────────────────────────────────────────────────────────╯

-- Return the selected text
local function get_text(comment_string, centered)
	local line_start_pos, line_end_pos = get_range()
	local text = vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)

	return format_lines(text, comment_string, centered)
end

-- Build the box
local function create_box(centered, choice)
	local borders = set_borders(choice)

	if borders.horizontal == " " and borders.top_right == " " then
		borders.horizontal = ""
		borders.top_right = ""
	end
	if borders.horizontal_bottom == " " and borders.bottom_right == " " then
		borders.horizontal_bottom = ""
		borders.bottom_right = ""
	end

	local trail = " "
	if borders.vertical_right == " " or borders.vertical_right == "" then
		borders.vertical_right = ""
		trail = ""
	end

	local comment_string = vim.bo.commentstring
	comment_string = comment_string:match("^(.*)%%s(.*)")
	if not comment_string then
		comment_string = ""
	end

	local ext_top_row = string.format(
		"%s %s%s%s",
		comment_string,
		borders.top_left,
		string.rep(borders.horizontal, settings.width - 2),
		borders.top_right
	)

	local ext_bottom_row = string.format(
		"%s %s%s%s",
		comment_string,
		borders.bottom_left,
		string.rep(borders.horizontal_bottom, settings.width - 2),
		borders.bottom_right
	)

	local inner_blank_line = string.format(
		"%s %s%s%s",
		comment_string,
		borders.vertical,
		string.rep(trail, settings.width - 2),
		borders.vertical_right
	)

	local int_row = ""
	local lines = {}

	if settings.outer_blank_lines then
		table.insert(lines, "")
	end

	table.insert(lines, ext_top_row)

	if settings.inner_blank_lines then
		table.insert(lines, inner_blank_line)
	end

	if centered then
		local text = get_text(comment_string, true)

		for _, line in pairs(text) do
			local pad, odd = get_pad(line)
			local parity_pad

			if odd then
				parity_pad = pad + 1
			else
				parity_pad = pad
			end

			local lead_space = " "
			if borders.vertical_right == "" and line == "" then
				lead_space = ""
			end

			int_row = string.format(
				"%s %s%s%s%s%s",
				comment_string,
				borders.vertical,
				string.rep(lead_space, parity_pad),
				line,
				string.rep(trail, pad),
				borders.vertical_right
			)

			table.insert(lines, int_row)
		end
	else
		local text = get_text(comment_string, false)

		for _, line in pairs(text) do
			local offset

			if line:find("^\t") then
				offset = 2
			else
				offset = 3
			end

			local pad = settings.width - vim.fn.strdisplaywidth(line) - offset

			local lead_space = " "
			if borders.vertical_right == "" and line == "" then
				lead_space = ""
			end

			int_row = string.format(
				"%s %s%s%s%s%s",
				comment_string,
				borders.vertical,
				lead_space,
				line,
				string.rep(trail, pad),
				borders.vertical_right
			)

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

-- Build a line
local function create_line(choice)
	local symbols = set_line(choice)

	local comment_string = vim.bo.commentstring

	comment_string = comment_string:match("^(.*)%%s(.*)")
	if not comment_string then
		comment_string = ""
	end
	line = string.format(
		"%s %s%s%s",
		comment_string,
		symbols.line_start,
		string.rep(symbols.line, settings.width - 2),
		symbols.line_end
	)
	return { line }
end

-- ╭────────────────────────────────────────────────────────────────────╮
-- │                          PUBLIC FUNCTIONS                          │
-- ╰────────────────────────────────────────────────────────────────────╯

-- Print the box with text left aligned
local function print_lbox(choice)
	local line_start_pos, line_end_pos = get_range()
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box(false, choice))
	vim.api.nvim_win_set_cursor(0, { set_cur_pos(line_end_pos), 1 })
end

-- Print the box with text centered
local function print_cbox(choice)
	local line_start_pos, line_end_pos = get_range()
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box(true, choice))
	vim.api.nvim_win_set_cursor(0, { set_cur_pos(line_end_pos), 1 })
end

-- Print a line
local function print_line(choice)
	local line = vim.fn.line(".")
	vim.api.nvim_buf_set_lines(0, line - 1, line, false, create_line(choice))
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
