" Plugin: vim-mysql-plugin
" Author: Ke Zhenxu <kezhenxu94@163.com>
" License: Apache License, Version 2.0
" Origin: https://github.com/kezhenxu94/vim-mysql-plugin

if exists("g:vim_mysql_plugin_loaded") || &cp
	finish
endif

let g:vim_mysql_plugin_loaded = 1

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

fun! g:RunArray(sqlarray, timing)
	if len(a:sqlarray) == 0
		echohl Error | echon 'Nothing Selected' | echohl None
		return
	endif

  if a:timing
    let l:thesql = ['SELECT NOW(3)+0 INTO @startTime;'] + a:sqlarray + ['SELECT CONCAT(ROUND(NOW(3) - @startTime, 3), "s") Took']
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
  call RunArray(['SELECT * FROM `' . l:Table . '` LIMIT 100;'], 0)
endfun

func! g:DescriptCursorTable()
	let l:Table = expand('<cword>')
  call RunArray(['SHOW FULL COLUMNS FROM `' . l:Table . '`;'], 0)
endfun

fun! g:RunInstruction()
	let l:PrevSemicolon = search(';', 'bnW')
	let l:NextSemicolon = search(';', 'nW')
	let l:Lines = getline(l:PrevSemicolon, l:NextSemicolon)[1:]
  call g:RunArray(l:Lines, 1)
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
