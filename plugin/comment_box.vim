if exists('g:loaded_comment_box') | finish | endif

let s:save_cpo = &cpo
set cpo&vim
command! -nargs=? CBlbox lua require("comment-box").lbox(<args>)
command! -nargs=? CBcbox lua require("comment-box").cbox(<args>)
command! -nargs=? CBline lua require("comment-box").line(<args>)
command! CBcatalog lua require("comment-box").catalog()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_comment_box = 1

