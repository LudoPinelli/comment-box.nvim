vim.api.nvim_create_user_command("CBllbox", function(opts)
  require("comment-box").llbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a left aligned box with text left aligned",
})

vim.api.nvim_create_user_command("CBlcbox", function(opts)
  require("comment-box").lcbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a left aligned box with text centered",
})

vim.api.nvim_create_user_command("CBlrbox", function(opts)
  require("comment-box").lrbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a left aligned box with text right aligned",
})

vim.api.nvim_create_user_command("CBclbox", function(opts)
  require("comment-box").clbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a centered box with text left aligned",
})

vim.api.nvim_create_user_command("CBccbox", function(opts)
  require("comment-box").ccbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a centered box with text centered",
})

vim.api.nvim_create_user_command("CBcrbox", function(opts)
  require("comment-box").crbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a centered box with text right aligned",
})

vim.api.nvim_create_user_command("CBrlbox", function(opts)
  require("comment-box").rlbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a right aligned box with text left aligned",
})

vim.api.nvim_create_user_command("CBrcbox", function(opts)
  require("comment-box").rcbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a right aligned box with text centered",
})

vim.api.nvim_create_user_command("CBrrbox", function(opts)
  require("comment-box").rrbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a right aligned box with text right aligned",
})

vim.api.nvim_create_user_command("CBalbox", function(opts)
  require("comment-box").albox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a left aligned adapted box",
})

vim.api.nvim_create_user_command("CBacbox", function(opts)
  require("comment-box").acbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a centered adapted box",
})

vim.api.nvim_create_user_command("CBarbox", function(opts)
  require("comment-box").arbox(opts.args, opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Print a right aligned adapted box",
})

vim.api.nvim_create_user_command("CBdbox", function(opts)
  require("comment-box").dbox(opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Remove a box",
})

vim.api.nvim_create_user_command("CBy", function(opts)
  require("comment-box").yank(opts.line1, opts.line2)
end, {
  nargs = "?",
  range = 2,
  desc = "Yank the content of a box",
})

vim.api.nvim_create_user_command("CBline", function(opts)
  require("comment-box").line(opts.args)
end, {
  nargs = "?",
  desc = "Print a left aligned line",
})

vim.api.nvim_create_user_command("CBcline", function(opts)
  require("comment-box").cline(opts.args)
end, {
  nargs = "?",
  desc = "Print a centered line",
})

vim.api.nvim_create_user_command("CBrline", function(opts)
  require("comment-box").rline(opts.args)
end, {
  nargs = "?",
  desc = "Print a right aligned line",
})

vim.api.nvim_create_user_command("CBcatalog", function()
  require("comment-box").catalog()
end, { desc = "Open the catalog" })
