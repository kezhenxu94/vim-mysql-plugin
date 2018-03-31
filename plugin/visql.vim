" Plugin: ViSQL (VIM MySQL database client)
" Author: Ke Zhenxu <kezhenxu94@163.com>
" License: GPL
" Origin: http://github.com/kezhenxu94/visql.vim

if exists("g:visql_loaded") || &cp
	finish
endif

let g:visql_loaded = 1

fun! g:RunShellCommand(shell_command)
	echohl String | echon '¦ $ ' . a:shell_command . '...' | echohl None

	silent! exe "noautocmd botright pedit ¦"
	noautocmd wincmd P
	setlocal modifiable
	setlocal nowrap
	normal ggdG

	set buftype=nofile
	silent! exe "noautocmd .! " . a:shell_command
	normal gg
	setlocal nomodifiable
	noautocmd wincmd p
	redraw!

	echohl Comment | echon 'Done! ' . a:shell_command | echohl None
endfun

fun! g:GetSelection()
	let [row1, col1] = getpos("'<")[1:2]
	let [row2, col2] = getpos("'>")[1:2]
	let lines = getline(row1, row2)
	if len(lines) == 0
		return []
	endif
	let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][col1 - 1:]
	return lines
endfun

fun! g:RunSelection()
	let l:Selection = g:GetSelection()
	if len(l:Selection) == 0
		echohl Error | echon 'Nothing Selected' | echohl None
		return
	endif
	call writefile(l:Selection, '/tmp/visql.sql', 'w')

	let l:Command = s:GetCommand() . ' < ' . '/tmp/visql.sql'
	let l:Command = escape(l:Command, '%#\`')
	call g:RunShellCommand(l:Command)
endf

func! g:SelectCursorTable()
	let l:Table = '`' . expand('<cword>') . '`'
	let l:Command = s:GetCommand() . ' -e ' . '"select * from ' . l:Table . '"'
	let l:Command = escape(l:Command, '%#\`')
	call g:RunShellCommand(l:Command)
endfun

func! g:DescriptCursorTable()
	let l:Table = '`' . expand('<cword>') . '`'
	let l:Command = s:GetCommand() . ' -e ' . '"show full columns from ' . l:Table . '"'
	let l:Command = escape(l:Command, '%#\`')
	call g:RunShellCommand(l:Command)
endfun

fun! g:RunLine()
	let l:CurrentLine = getline('.')
	let l:Command = s:GetCommand() . ' -e "' . l:CurrentLine . '"'
	let l:Command = escape(l:Command, '%#\`')
	call g:RunShellCommand(l:Command)
endfun

fun! s:GetCommand()
	let l:Command = 'mysql '
	let l:LineNum = 1
	let l:Line = getline(l:LineNum)
	while l:Line != '--'
		let l:Command .= substitute(l:Line, '^--\s*\(.*\)$', '\1', 'g')
		let l:LineNum = l:LineNum + 1
		let l:Line = getline(l:LineNum)
	endwhile
	return l:Command
endfun

autocmd FileType mysql nnoremap <silent><buffer> <leader>rr :call g:RunLine()<CR>
autocmd FileType mysql nnoremap <silent><buffer> <leader>ss :call g:SelectCursorTable()<CR>
autocmd FileType mysql nnoremap <silent><buffer> <leader>ds :call g:DescriptCursorTable()<CR>
autocmd FileType mysql nnoremap <silent><buffer> <leader>rs :call g:RunSelection()<CR>
autocmd FileType mysql vnoremap <silent><buffer> <leader>rs :<C-U>call g:RunSelection()<CR>
