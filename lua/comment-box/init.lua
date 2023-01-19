--         ╭──────────────────────────────────────────────────────────╮
--         │                         SETTINGS                         │
--         ╰──────────────────────────────────────────────────────────╯

---@class CommentBoxConfig
local settings = {
	doc_width = 80,
	box_width = 60,
	borders = {
		top = "─",
		bottom = "─",
		left = "│",
		right = "│",
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
	},
	line_width = 60,
	lines = {
		line = "─",
		line_start = "─",
		line_end = "─",
	},
	outer_blank_lines = false,
	inner_blank_lines = false,
	line_blank_line_above = false,
	line_blank_line_below = false,
}

--         ╭──────────────────────────────────────────────────────────╮
--         │                     LOCAL VARIABLES                      │
--         ╰──────────────────────────────────────────────────────────╯

local cat = require("comment-box.catalog")
local catalog = require("comment-box.catalog_view")

---@type string
local comment_string
---@type number, number
local line_start_pos, line_end_pos

---@type boolean
local centered_text
---@type boolean
local centered_box
---@type number
local final_box_width
---@type boolean
local adapted

---@type string, string
local lead_space_ab, lead_space_bb

--         ╭──────────────────────────────────────────────────────────╮
--         │                          UTILS                           │
--         ╰──────────────────────────────────────────────────────────╯

-- Compute padding
local function get_pad(line)
	local start_pad = math.floor((final_box_width - vim.fn.strdisplaywidth(line)) / 2)
	local end_pad = final_box_width - (start_pad + vim.fn.strdisplaywidth(line))

	return start_pad, end_pad
end

-- Store the range of the selected text in 'line_start_pos'/'line_end_pos'
---@param lstart? number
---@param lend? number
local function get_range(lstart, lend)
	local mode = vim.api.nvim_get_mode().mode

	if lstart and lend and lend ~= lstart then
		line_start_pos = lstart
		line_end_pos = lend
	else
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
	end
end

-- Return the correct cursor position after a box has been created
---@param end_pos number
---@return number
local function set_cur_pos(end_pos)
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
---@param line string
---@return string
local function skip_cs(line)
	local trimmed_line = vim.trim(line)
	local cs_len = vim.fn.strdisplaywidth(comment_string)

	if trimmed_line:sub(1, cs_len) == comment_string then
		line = line:gsub(vim.pesc(comment_string), "", 1) -- remove comment string
		line = line:gsub("[ \t]+%f[\r\n%z]", "") -- remove trailing spaces
	end
	if centered_text then
		return vim.trim(line) -- if centered need to trim both ends for correct padding
	else
		return line
	end
end

-- Wrap lines too long to fit in box
---@param text string
---@return string[]
local function wrap(text)
	local str_tab = {}
	local str = text:sub(1, final_box_width - 6)
	local rstr = str:reverse()
	local f = rstr:find(" ")

	f = final_box_width - 6 - f
	table.insert(str_tab, string.sub(text, 1, f))
	table.insert(str_tab, string.sub(text, f + 1))
	return str_tab
end

-- Prepare each line and rewrote the table in case of wraping lines
---@param text string[]
local function format_lines(text)
	final_box_width = 0
	for pos, str in ipairs(text) do
		table.remove(text, pos)
		str = skip_cs(str)
		table.insert(text, pos, str)
		if adapted then
			if vim.fn.strdisplaywidth(str) >= settings.doc_width - 2 then
				final_box_width = settings.doc_width - 2
			elseif vim.fn.strdisplaywidth(str) > final_box_width and final_box_width < settings.doc_width - 2 then
				final_box_width = vim.fn.strdisplaywidth(str) + 2
			end
		else
			final_box_width = settings.box_width - 2
		end
		if vim.fn.strdisplaywidth(str) > final_box_width then
			local to_insert = wrap(str)
			for ipos, st in ipairs(to_insert) do
				table.insert(text, pos + ipos, st)
			end
			table.remove(text, pos)
		end
	end
	return text
end

-- Set the symbols used to draw the box
---@param choice number?
---@return table
local function set_borders(choice)
	choice = choice or 0
	local borders
	if choice == 0 then
		borders = settings.borders
	else
		borders = cat.boxes[choice] or settings.borders
	end
	return borders
end

-- Set the symbols used to draw the line
---@param choice number?
---@return table
local function set_line(choice)
	choice = choice or 0
	local symbols
	if choice == 0 then
		symbols = settings.lines
	else
		symbols = cat.lines[choice] or settings.lines
	end
	return symbols
end

---@return string
---@return string
function set_lead_space()
	lead_space_ab = " "
	lead_space_bb = " "
	if centered_box then
		lead_space_bb = string.rep(
			" ",
			math.floor((settings.doc_width - final_box_width) / 2 - vim.fn.strdisplaywidth(comment_string) + 0.5)
		)
	end

	return lead_space_ab, lead_space_bb
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                           CORE                           │
--         ╰──────────────────────────────────────────────────────────╯

-- Return the selected text
---@return string[]
local function get_text()
	local text = vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
	return format_lines(text)
end

-- Build the box
---@param choice number?
local function create_box(choice)
	local borders = set_borders(choice)

	comment_string = vim.bo.commentstring:match("^(.*)%%s(.*)")
	if not comment_string or vim.bo.filetype == "markdown" or vim.bo.filetype == "org" then
		comment_string = ""
	end

	local text = get_text()
	local trail = " "

	-- ╓                                                       ╖
	-- ║ Deal with the two ways to declare transparent borders ║
	-- ╙                                                       ╜

	if borders.top_left == "" then
		borders.top_left = " "
	end
	if borders.bottom_left == "" then
		borders.bottom_left = " "
	end
	if borders.top_right == " " then
		borders.top_right = ""
	end
	if borders.bottom_right == " " then
		borders.top_right = ""
	end
	if borders.top == "" then
		borders.top = " "
	end
	if borders.bottom == "" then
		borders.bottom = " "
	end
	if borders.right == " " or borders.right == "" then
		borders.right = ""
		trail = ""
	end
	if borders.left == "" then
		borders.left = " "
	end
	if borders.top == " " and borders.top_right == "" then
		borders.top = ""
	end
	if borders.bottom == " " and borders.bottom_right == "" then
		borders.bottom = ""
	end

	lead_space_ab, lead_space_bb = set_lead_space()
	if borders.top_right == "" and borders.top == "" then
		lead_space_ab = ""
		if borders.top_left == " " then
			borders.top_left = ""
			lead_space_bb = ""
		end
	end
	if borders.bottom_right == "" and borders.bottom == "" then
		lead_space_ab = ""
		if borders.bottom_left == " " then
			borders.bottom_left = ""
			lead_space_bb = ""
		end
	end

	local ext_top_row = string.format(
		"%s%s%s%s%s",
		comment_string,
		lead_space_bb,
		borders.top_left,
		string.rep(borders.top, final_box_width),
		borders.top_right
	)

	local ext_bottom_row = string.format(
		"%s%s%s%s%s",
		comment_string,
		lead_space_bb,
		borders.bottom_left,
		string.rep(borders.bottom, final_box_width),
		borders.bottom_right
	)

	local inner_blank_line = string.format(
		"%s%s%s%s%s",
		comment_string,
		lead_space_bb,
		borders.left,
		string.rep(trail, final_box_width),
		borders.right
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

	if centered_text then
		-- ╓                  ╖
		-- ║ If text centered ║
		-- ╙                  ╜

		for _, line in pairs(text) do
			local start_pad, end_pad = get_pad(line)

			lead_space_ab, lead_space_bb = set_lead_space()
			if borders.right == "" and line == "" then
				lead_space_ab = ""
				if borders.left == " " or borders.left == "" then
					lead_space_bb = ""
					borders.left = ""
				end
			end

			int_row = string.format(
				"%s%s%s%s%s%s%s",
				comment_string,
				lead_space_bb,
				borders.left,
				string.rep(lead_space_ab, start_pad),
				line,
				string.rep(trail, end_pad),
				borders.right
			)

			table.insert(lines, int_row)
		end
	else
		-- ╓                        ╖
		-- ║ If text left justified ║
		-- ╙                        ╜

		for _, line in pairs(text) do
			local offset = 1

			if not centered_box and line:find("^\t") then
				offset = 0
			end

			local pad = final_box_width - vim.fn.strdisplaywidth(line) - offset

			lead_space_ab, lead_space_bb = set_lead_space()
			trail = " "
			if borders.right == "" and line == "" then
				lead_space_ab = ""
				trail = ""
				pad = 0
				if borders.left == " " or borders.left == "" then
					lead_space_bb = ""
					borders.left = ""
				end
			end

			int_row = string.format(
				"%s%s%s%s%s%s%s",
				comment_string,
				lead_space_bb,
				borders.left,
				lead_space_ab,
				line,
				string.rep(trail, pad),
				borders.right
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
---@param choice number?
---@param centered_line boolean
local function create_line(choice, centered_line)
	local symbols = set_line(choice)
	comment_string = vim.bo.commentstring
	local line = {}
	local lead_space = " "
	if centered_line then
		lead_space = string.rep(
			" ",
			math.floor((settings.doc_width - settings.line_width) / 2 - vim.fn.strdisplaywidth(comment_string))
		)
	end

	comment_string = comment_string:match("^(.*)%%s(.*)")
	if not comment_string or vim.bo.filetype == "markdown" or vim.bo.filetype == "org" then
		comment_string = ""
	end
	if settings.line_blank_line_above then
		table.insert(line, "")
	end
	table.insert(
		line,
		string.format(
			"%s%s%s%s%s",
			comment_string,
			lead_space,
			symbols.line_start,
			string.rep(symbols.line, settings.line_width - 2),
			symbols.line_end
		)
	)
	if settings.line_blank_line_below then
		table.insert(line, "")
	end
	return line
end

---@param choice number?
---@param lstart number?
---@param lend number?
local function display_box(choice, lstart, lend)
	get_range(lstart, lend)
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box(choice))
	-- Move the cursor to match the result
	vim.api.nvim_win_set_cursor(0, { set_cur_pos(line_end_pos), 1 })
end

---@param choice number?
---@param centered_line boolean
local function display_line(choice, centered_line)
	local line = vim.fn.line(".")
	vim.api.nvim_buf_set_lines(0, line - 1, line, false, create_line(choice, centered_line))

	local cur = vim.api.nvim_win_get_cursor(0)
	if settings.line_blank_line_below then
		cur[1] = cur[1] + 1
	end
	if settings.line_blank_line_above then
		cur[1] = cur[1] + 1
	end
	vim.api.nvim_win_set_cursor(0, cur)
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                     PUBLIC FUNCTIONS                     │
--         ╰──────────────────────────────────────────────────────────╯

-- Print a left aligned box with text left aligned
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_lbox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = false
	centered_box = false
	adapted = false
	display_box(choice, lstart, lend)
end

-- Print a left aligned box with text centered
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_cbox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = true
	centered_box = false
	adapted = false
	display_box(choice, lstart, lend)
end

-- Print a centered box with text left aligned
---@param choice number?
local function print_clbox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = false
	centered_box = true
	adapted = false
	display_box(choice, lstart, lend)
end

-- Print a centered box with text centered
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_ccbox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = true
	centered_box = true
	adapted = false
	display_box(choice, lstart, lend)
end

-- Print a left aligned box with text left aligned
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_albox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = false
	centered_box = false
	adapted = true
	display_box(choice, lstart, lend)
end

-- Print a left aligned box with text centered
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_acbox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = true
	centered_box = false
	adapted = true
	display_box(choice, lstart, lend)
end

-- Print a centered box with text left aligned
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_aclbox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = false
	centered_box = true
	adapted = true
	display_box(choice, lstart, lend)
end

-- Print a centered box with text centered
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_accbox(choice, lstart, lend)
	choice = tonumber(choice)
	lstart = tonumber(lstart)
	lend = tonumber(lend)
	centered_text = true
	centered_box = true
	adapted = true
	display_box(choice, lstart, lend)
end

-- Print a left aligned line
---@param choice number?
local function print_line(choice)
	choice = tonumber(choice)
	local centered_line = false
	display_line(choice, centered_line)
end

-- Print a centered line
---@param choice number?
local function print_cline(choice)
	choice = tonumber(choice)
	local centered_line = true
	display_line(choice, centered_line)
end

local function open_catalog()
	catalog.view_cat()
end

-- Config
---@param config? CommentBoxConfig
local function setup(config)
	settings = vim.tbl_deep_extend("force", settings, config or {})
end

return {
	lbox = print_lbox,
	cbox = print_cbox,
	clbox = print_clbox,
	ccbox = print_ccbox,
	albox = print_albox,
	acbox = print_acbox,
	aclbox = print_aclbox,
	accbox = print_accbox,
	line = print_line,
	cline = print_cline,
	catalog = open_catalog,
	setup = setup,
}
