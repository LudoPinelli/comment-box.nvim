if exists('g:loaded_comment_box') | finish | endif

let s:save_cpo = &cpo
set cpo&vim
command! -nargs=? -range CBlbox lua require("comment-box").lbox("<args>","<line1>","<line2>")
command! -nargs=? -range CBcbox lua require("comment-box").cbox("<args>", "<line1>", "<line2>")
command! -nargs=? CBline lua require("comment-box").line(<args>)
command! CBcatalog lua require("comment-box").catalog()
" lua vim.api.nvim_add_user_command("CBlbox", "lua require('comment-box').lbox(<line1>,<line2>,<args>)", {})

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_comment_box = 1

