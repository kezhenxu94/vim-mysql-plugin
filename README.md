# vim-mysql-plugin

A highly customizable MySQL VIM plugin.

[![Mentioned in Awesome VIM](https://awesome.re/mentioned-badge.svg)](https://github.com/akrawchyk/awesome-vim/)

## Prerequisite

This plugin works on the basis of MySQL client, therefore a MySQL client is required, use the following command to ensure that there is one available on your machine:

```shell
$ mysql --version
mysql  Ver 14.14 Distrib 5.7.16, for osx10.11 (x86_64) using  EditLine wrapper
```

If the output is something like `-bash: mysql: command not found`, then you may need to install a MySQL client first.

## Installation Options

1. [Install with Vundle](#install-with-vundle) (recommended)
2. [Install with Plug](#install-with-plug) (for neovim)
3. [Manually Install](#manually-install)

### Install with Vundle
(recommended)

Add the following line to the ~/.vimrc file, after adding that, the file may look like this:

```vimrc
" ... some other configurations
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
" Add this plugin
Plugin 'git://github.com/kezhenxu94/vim-mysql-plugin.git'
call vundle#end()
" ... some other configurations
```

And remember to execute `:PluginInstall` in VIM normal mode.

### Install with Plug
(for neovim)

Add the following to `~/.config/nvim/init.vim`:
```vimrc
" ... some other configurations
Plugin 'https://github.com/kezhenxu94/vim-mysql-plugin.git'
" ... some other configurations
```

Then run `:PlugInstall`.

### Manually Install

Be sure you have `git` installed and configured to [authenticate to github.com via ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).
In your terminal...issue the following commands, one by one (this assumes you have `git` installed and configured):

```
cd ~;
git clone git@github.com:kezhenxu94/vim-mysql-plugin.git;
ls -lah ~/vim-mysql-plugin/plugin/vim-mysql-plugin.vim;
echo "let mapleader = '\'" >> ~/.vimrc;
echo "source ~/vim-mysql-plugin/plugin/vim-mysql-plugin.vim" >> ~/.vimrc;
```

## Usage

There are two things to do after installation:

1. Put your database credentials in `~/my.cnf`

```
[client]
user=your_user_here

[clientAnysuffix]
database=mydb"
```

2. Use vim to issue mysql commands!

- `vim anyfile` (so that you can type your sql)
 - typically using a file with name ending in `.sql` is best (for syntax highlighting)
- at the top of the file you may put command line args (but one is mandatory)
 - the `--defaults-group-suffix` has to be there (at least the `database` parameter must be set)
   - the suffix is a personal choice but it must match what is in your my.cnf (see "Anysuffix" in example)
   - [read more about defaults-group-suffix](https://dev.mysql.com/doc/refman/5.5/en/option-file-options.html#option_general_defaults-group-suffix)
 - the `--login-path` option is useful
   - this can be set to makes use of `mysql_config_editor` created `my_login.cnf` files
   - the syntax for this is `--login-path=<configured db path>` for instance `--login-path=myMysql`
 - the `-t` switch sets the output to table
   - omit this to get raw, tabbed output
   - omit this and replace the semi-colon at the end of the query with '\G' to get vertical format
 - each mysql option **must** be on its own line

```
-- --defaults-group-suffix=Anysuffix
-- -t
--

SELECT * FROM USER;
```
- Query `SELECT * FROM USER` with these keystrokes _(`<CR>` is carriage return/"enter")_:

```
/SELECT<CR>
V
\rs
```

The following is a description of the commands including an explanation of the `\SELECT<CR>V\rs` sequence:

- `/SELECT` then *<CR>* moves your cursor (via *search*) to the query
- `V` *shift+v* selects the entire query (line)
- `\rs` issues `<leader>`+rs
 - earlier we set `mapleader` to backslash _(change it in .vimrc)_

Query results appear in a split pane.

Remember to delimit your queries with semi-colons.

### Command Reference

- `<leader>rr` "Run Instruction"
- `<leader>ss` "Select Cursor Table"
- `<leader>ds` "Descript Cursor Table"
- `<leader>rs` "Run Selection"
- `<leader>re` "Run Explain"

"Run Instruction" executes query and can be run from anywhere within the query.

"Explain" can be run from anywhere within the query.

"Selection" means select _query_ before issuing command.

"Cursor" means place your cursor on _the table_ to issue command.

"Selection" means select _query_ before issuing command.

### Usage Notes

If you already use `.my.cnf`, then add the new `[clientAnySuffix]` group at the end. As your configuration options will be read after the main `[Client]` ones, you do not need to repeat those if the values are the same, for example, to set up a section for a particular database using your normal credential, your `.my.cnf` might look like this:

```conf
[client]
user = mymysqlmamaria
password = neveryoumind

# ↑ that config was there before
# ↓ this config is what we added
[clientMyDb]
database = mydb
```

This is because `database` must be set, when the query is issued the database must already be selected.

Remember, add your sql statements following the three lines. Here is another sample `sql.sql` file:

```sql.sql
-- --defaults-group-suffix=ExampleTest
-- -t
--

SELECT * FROM USER;
```

Here are more examples of how to run `SELECT * FROM USER:`

- Position caret/cursor on line `SEELCT * FROM USER;` and (in VIM normal mode) type `<leader>rr`
 - if the query does not run, but instead a replacement of the character underneath the cursor occurs your `<leader>` is not set
  - to set `<leader>` to the recommended backslash place `let mapleader = '\'` in your `.vimrc`

- Position caret/cursor on (within) the table name (`USER`) and type `<leader>ds` (stands for "Descript") to show the columns of the table
- Type `<leader>ss` to select all from the `USER` table

- Using VIM visual mode, select a range of statement and type `<leader>rs` to execute the selected statements
 - the results (if multiple queries selected) will stack in the result window

Remember, after typing the shortcut the VIM window will be splitted into two, the bottom of which will show the result of the statement.
Switch windows by typing [Cntl-W]+[W]. [Read more about split window navigation in VIM](http://vimdoc.sourceforge.net/htmldoc/windows.html#window-move-cursor)

Remember to delimit your queries with semi-colons.

## Contribution

If you find it difficult to use this plugin, please open issues or help to improve it by creating pull requests.

## Change log

- Added a simplified install sequence with some descriptions that may be useful for those just getting started in vim.

- Security improvement: all shell commands are escaped with shellescape(). This means MySQL command options must now be one-per-line.

- Security improvement: Previously SQL with double quotes `"` that was run with `<Leader>rr` would escape the shell argument, meaning the following code was run in the shell(!). This would potentially do very bad things.

- Code refactor: all SQL execution now uses the same method (write it to a /tmp file and `<` redirect it into the command; we no longer use `-e` with SQL on the command line)

- Timings: An additional query is run to report on the execution time.
