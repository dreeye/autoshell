syntax on
set backspace=indent,eol,start "退格键
set history=1000	" 记录命令行模式命令历史和搜索历史1000行列表
set nobackup		" 不自动备份文件~
set undofile		" 记录撤销命令写入文件
set undodir=/tmp/vimbak " 撤销命令文件路径
set undolevels=1000	" 撤销记录次数
set showcmd		" 在一般模式，命令输入过程会显示在右下角，比如zz,zt,zb
set incsearch 		" 搜索时关键字逐字符高亮
set number              " 行号
colorscheme desert      " 模板样式
set tabstop=4		" 设定tab宽度为4个字符
set shiftwidth=4 	" 设定自动缩进为4个字符
set expandtab		" 用space替代tab的输入
set laststatus=2	" 默认打开状态栏
set statusline=%<%F%h%m%r%h%w\ %=%l\,%L\ %{&fileencoding}	"自定义状态栏
" NERDTree插件
nmap <silent> <c-b> :NERDTreeToggle<CR>	
" 如果直接打开vim而不指定文件，打开nerdtree
autocmd vimenter * if !argc() | NERDTree | endif
" 如果vim最后编辑的文件也退出，文件的nerdtree也退出
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
"前一个标签页
nmap <silent> <c-n> :tabp<CR>
"后一个标签页
nmap <silent> <c-m> :tabn<CR>
"行号和相对行号的切换
function Checknum()
  if &rnu
     set number
  else
     set relativenumber
  endif
endfunction
nmap <F3> :call Checknum()<CR>
"php 功能
"php打印输出
nmap <F2> iecho '<pre>';print_r();echo '</pre>';exit(); <ESC> 
" 匹配class 中的方法和属性
nmap <F7> :g/^\s*\(\(\<public\\|protected\\|private\>\)\s\+\(static\s\+\)\=\)\=function\s\+\w\+(<CR>
nmap <F6> :g/^\s*\(\<public\\|protected\\|private\>\)\s\+\$/<CR>
"插入注释
nmap <F5> i/**<CR><Space>*<CR><Space>*<CR><Space>*<CR><Space>*<CR><Space>*/<ESC>
set fencs=utf-8,chinese,latin1 fenc=utf-8 enc=utf-8
