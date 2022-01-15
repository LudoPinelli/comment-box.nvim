package.loaded["comment-box"] = nil
package.loaded["dev"] = nil

vim.keymap.set("n", ",r", "<Cmd>luafile dev/init.lua<CR>", {})
local cbox = require("comment-box")
vim.keymap.set({ "n", "v" }, "<Leader>bb", cbox.lbox, {})
vim.keymap.set({ "n", "v" }, "<Leader>bc", cbox.cbox, {})
vim.keymap.set("n", "<Leader>bl", cbox.line, {})
