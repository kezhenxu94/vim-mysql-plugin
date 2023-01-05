" Plugin: vim-mysql-plugin
" Author: Ke Zhenxu <kezhenxu94@163.com>
" License: Apache License, Version 2.0
" Origin: https://github.com/kezhenxu94/vim-mysql-plugin

if exists("g:vim_mysql_plugin_loaded") || &cp
	finish
endif

let g:vim_mysql_plugin_loaded = 1
let g:vim_mysql_plugin_sqleof = ';'

fun! g:RunShellCommand(shell_command)
	echohl String | echon '$ ' . a:shell_command[0:winwidth(0)-11] . '...' | echohl None

	silent! exe "noautocmd botright pedit ¦"
	noautocmd wincmd P
	setl stl =Running...please\ wait
	redraw
	setlocal modifiable
	setlocal nowrap
	normal ggdG

	set buftype=nofile
	silent! exe "noautocmd .! " . a:shell_command
	exe 'setl stl=Done'
	normal gg
	setlocal nomodifiable
	noautocmd wincmd p
	redraw!

	echohl Comment | echon '$ '. a:shell_command[0:winwidth(0)-11] . '...' | echohl None
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

fun! g:RunArray(sqlarray, timing)
	if len(a:sqlarray) == 0
		echohl Error | echon 'Nothing Selected' | echohl None
		return
	endif

	if a:timing
		let l:thesql = ['SELECT NOW(3)+0 INTO @startTime;'] + a:sqlarray + ['; SELECT CONCAT(ROUND(NOW(3) - @startTime, 3), "s") Took\G']
	else
		let l:thesql = a:sqlarray
	endif
	call writefile(l:thesql, '/tmp/vim-mysql-plugin.sql')
	let l:Command = s:GetCommand() . ' </tmp/vim-mysql-plugin.sql'
	call g:RunShellCommand(l:Command)
endf

fun! g:RunSelection()
	let l:Selection = g:GetSelection()
	call g:RunArray(l:Selection, 1)
endfun


func! g:SelectCursorTable()
	let l:Table = expand('<cword>')
	call RunArray(['SELECT * FROM `' . l:Table . '` LIMIT 100' . g:vim_mysql_plugin_sqleof], 0)
endfun

func! g:DescriptCursorTable()
	let l:Table = expand('<cword>')
	call RunArray(['SHOW FULL COLUMNS FROM `' . l:Table . '`' . g:vim_mysql_plugin_sqleof], 0)
endfun

fun! s:SetEosql(line)
	let eosql = getline(a:line)
	let m = matchstr(eosql, ';')
	if (empty(m))
		let g:vim_mysql_plugin_sqleof = '\G'
	else
		let g:vim_mysql_plugin_sqleof = ';'
	endif
endfun

fun! s:GetInstruction()
	let l:p = '\(\G\|;\)'
	let l:PrevSemicolon = search(l:p, 'bnW')
	let l:NextSemicolon = search(l:p, 'cnW')
	call s:SetEosql(l:NextSemicolon)
	return getline(l:PrevSemicolon, l:NextSemicolon)[1:]
endfun

fun! g:RunInstruction()
	let l:Lines = s:GetInstruction()
	call g:RunArray(l:Lines, 1)
endfun

fun! g:RunExplain()
	let l:Lines = s:GetInstruction()
	call g:RunArray(['explain '] + l:Lines, 1)
endfun

fun! g:RunExplainSelection()
	let l:Selection = g:GetSelection()
	call g:RunArray(['explain '] + l:Selection, 1)
endfun

fun! s:GetCommand()
	let l:Command = 'mysql '
	let l:LineNum = 1
	let l:Line = getline(l:LineNum)
	while l:Line != '--'
		let l:arg = shellescape(substitute(l:Line, '^--\s*\(.*\)$', '\1', 'g'))
		let l:Command .= l:arg . ' '
		let l:LineNum = l:LineNum + 1
		let l:Line = getline(l:LineNum)
	endwhile
	return l:Command
endfun

autocmd FileType sql nnoremap <silent><buffer> <leader>rr :call g:RunInstruction()<CR>
autocmd FileType sql nnoremap <silent><buffer> <leader>ss :call g:SelectCursorTable()<CR>
autocmd FileType sql nnoremap <silent><buffer> <leader>ds :call g:DescriptCursorTable()<CR>
autocmd FileType sql nnoremap <silent><buffer> <leader>rs :call g:RunSelection()<CR>
autocmd FileType sql vnoremap <silent><buffer> <leader>rs :<C-U>call g:RunSelection()<CR>
autocmd FileType sql nnoremap <silent><buffer> <leader>re :call g:RunExplain()<CR>
autocmd FileType sql vnoremap <silent><buffer> <leader>re :call g:RunExplainSelection()<CR>
