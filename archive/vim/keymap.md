# [keymap & autocmd & vim-setting](archive/vim/keymap)

## 查看keymap

:map 显示所有keymap，插件的快捷键设定在前面，个人的快捷键设定通常在最后

:h key-notation 列出快捷键组合键的愈发==写法

## inoremap和imap

inoremap的意思是避免【循环参照】的insert模式快捷键

## LeaderKey

> let mapleader = ","

如果想用i当快捷键，可以在i前面加个LeaderKey告诉vim我接下来按的i不是进入insert模式

默认的LeaderKey是反斜杠，业界通用的LeaderKey就是逗号

## 我的keymap设定

```
imap jj <Esc>
imap ,w <Esc>:w<CR>
imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>
nmap 1o o<Esc>k
nmap 2o o<Esc>j                                                                                                                                                             
nmap zz :q!<CR>
vmap <Tab> >>
vmap <S-Tab> <<

if executable("ruby")
  autocmd BufRead,BufNewFile *.rb noremap <F1> :% w !ruby -w<CR>
endif
```

## autocmd（自动命令）

类似的js的Event处理，应用：保存的时候自动把句尾的多余空白删掉

### 应用:保存时去掉行末多余空格

先通过 :set list 显示所有换行符

:autocmd BufferWritePre * :%s/\s\\+$//e

解释下正则表达式:
- \s表示一个空白
- +表示一个以上
- $表示结尾
- vim置换的/e表示从右往左进行匹配

## 我的vim设定

> [!NOTE]
> 可以利用source命令导入其他文件中的vim设定,从而把一个很长的vimrc拆分成好几个文件

```
set ruler "show coordinate on bottom-right
set showcmd "show cmd when typing                                                                                                                                           
set scrolloff=3 "start scolldown when 3 line below screen
set ignorecase
set smartcase
set cursorline
"set cursorcolumn
"cursorline only actived window
augroup CursorLine
    au! 
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END 
```

解释其中几条设置:
- showcmd用于显示已输入但未完成的命令，但在我电脑上vimrc此条不生效
- scrolloff=3的意思是光标离屏幕还差三行的时候开始滚动屏幕
- au WinLeave * setlocal nocursorline：
- ..au全称autcm，d星号表示所有文件
