print("Comment-box dev branch")

vim.api.nvim_create_user_command(
	'CBlbox',
	function(opts)
		require 'comment-box.init'.lbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a left aligned box with text left aligned',
	}
)

vim.api.nvim_create_user_command(
	'CBllbox',
	function(opts)
		require 'comment-box.init'.llbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a left aligned box with text left aligned',
	}
)

vim.api.nvim_create_user_command(
	'CBcbox',
	function(opts)
		require 'comment-box.init'.cbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a left aligned box with text centered',
	}
)

vim.api.nvim_create_user_command(
	'CBlcbox',
	function(opts)
		require 'comment-box.init'.lcbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a left aligned box with text centered',
	}
)

vim.api.nvim_create_user_command(
	'CBlrbox',
	function(opts)
		require 'comment-box.init'.lrbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a left aligned box with text right aligned',
	}
)

vim.api.nvim_create_user_command(
	'CBclbox',
	function(opts)
		require 'comment-box.init'.clbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a centered box with text left aligned',
	}
)

vim.api.nvim_create_user_command(
	'CBccbox',
	function(opts)
		require 'comment-box.init'.ccbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a centered box with text centered',
	}
)

vim.api.nvim_create_user_command(
	'CBcrbox',
	function(opts)
		require 'comment-box.init'.crbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a centered box with text right aligned',
	}
)

vim.api.nvim_create_user_command(
	'CBrlbox',
	function(opts)
		require 'comment-box.init'.rlbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a right aligned box with text left aligned',
	}
)

vim.api.nvim_create_user_command(
	'CBrcbox',
	function(opts)
		require 'comment-box.init'.rcbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a right aligned box with text centered',
	}
)

vim.api.nvim_create_user_command(
	'CBrrbox',
	function(opts)
		require 'comment-box.init'.rrbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a right aligned box with text right aligned',
	}
)

vim.api.nvim_create_user_command(
	'CBalbox',
	function(opts)
		require 'comment-box.init'.albox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a left aligned adapted box',
	}
)

vim.api.nvim_create_user_command(
	'CBacbox',
	function(opts)
		require 'comment-box.init'.acbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a centered adapted box',
	}
)

vim.api.nvim_create_user_command(
	'CBarbox',
	function(opts)
		require 'comment-box.init'.arbox(opts.args, opts.line1, opts.line2)
	end,
	{
		nargs = '?',
		range = 2,
		desc = 'Print a right aligned adapted box',
	}
)

vim.api.nvim_create_user_command(
	'CBline',
	function(opts)
		require 'comment-box.init'.line(opts.args)
	end,
	{
		nargs = '?',
		desc = 'Print a left aligned line'
	}
)

vim.api.nvim_create_user_command(
	'CBcline',
	function(opts)
		require 'comment-box.init'.cline(opts.args)
	end,
	{
		nargs = '?',
		desc = 'Print a centered line'
	}
)

vim.api.nvim_create_user_command(
	'CBcatalog',
	function()
		require 'comment-box.init'.catalog()
	end,
	{ desc = 'Open the catalog' }
)
