# vim-mysql-plugin

A highly customizable MySQL VIM plugin.

## Prerequisite

This plugin works on the basis of MySQL client, therefore a MySQL client is required, use the following command to ensure that there is one available on your machine:

```shell
$ mysql --version
mysql  Ver 14.14 Distrib 5.7.16, for osx10.11 (x86_64) using  EditLine wrapper
```

If the output is something like `-bash: mysql: command not found`, then you may need to install a MySQL client first.

## Install

- Vundle (Recommended)

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

- Plug (for neovim)

Add the following to `~/.config/nvim/init.vim`:
```vimrc
" ... some other configurations
Plugin 'https://github.com/kezhenxu94/vim-mysql-plugin.git'
" ... some other configurations
```

Then run `:PlugInstall`.


## How does it work

For the sake of security and convenience, this plugin utilizes a command line parameter of MySQL client called `defaults-group-suffix`, for more details about `defaults-group-suffix`, check out the documentation [here](https://dev.mysql.com/doc/refman/5.5/en/option-file-options.html#option_general_defaults-group-suffix); but now just put your configuration in the file `~/.my.cnf` like this:

```conf
[ClientExampleTest]
host = localhost
user = root
password = root
default_character_set = utf8
database = mysql

[ClientExampleProd]
host = localhost
user = root
password = root
default_character_set = utf8
database = mysql
```

**Note**: if you already use `.my.cnf`, then add the new contents at the end. As your configuration options will be read after the main `[Client]` ones, you do not need to repeat those if the values are the same, for example, to set up a section for a particular database using your normal credials, your `.my.cnf` might look like this:

```conf
[client]
user = mymysqlmamaria
password = neveryoumind

# ↑ that config was there before
# ↓ this config is what we added
[client-mydb]
database = mydb
```

## Usage

Create a new file whose name ends with `.sql`, adding the following two lines in the very beginning of the file:

```sql
-- --defaults-group-suffix=ExampleTest -t
--
```

Then add your sql statements following the two lines. Here is a sample of the `sql` file:

```sql
-- --defaults-group-suffix=ExampleTest -t
--
   
select * from user;
```

**Note**: The `--default-group-suffix` option is a *suffix*, i.e. we're entering `ExampleTest` not `ClientExampleTest`. To use the 2nd configuration example you'd use `--default-group-suffix=mydb`.

- Move the caret to the line `select * from user;` and type `<leader>rr` in VIM normal mode to run the line;

- Move the caret to the table name (such as `user`) and type `<leader>ds` (stands for "Descript") to show the columns of the table, type `<leader>ss` to `select *` from the table;

- Using VIM visual mode to select a range of statement and type `<leader>rs` to execute the selected statements;

> `<leader>` is the "leading key" when mapping a shortcut to a specific function, the default `<leader>` may be `\`

After typing the shortcut the VIM window will be splitted into two, the bottom of which will show the result of the statement;

## Contribution

If you find it difficult to use this plugin, please open issues or help improve it by creating pull requests.

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
| [<img src="https://avatars3.githubusercontent.com/u/15965696?v=4" width="50px;"/><br /><sub><b>kezhenxu94</b></sub>](https://kezhenxu94.me)<br />[💻](https://github.com/kezhenxu94/vim-mysql-plugin/commits?author=kezhenxu94 "Code") | [<img src="https://avatars2.githubusercontent.com/u/13188781?v=4" width="50px;"/><br /><sub><b>jfecher</b></sub>](http://antelang.org/)<br />[💻](https://github.com/kezhenxu94/vim-mysql-plugin/commits?author=jfecher "Code") |
| :---: | :---: |
<!-- ALL-CONTRIBUTORS-LIST:END -->
