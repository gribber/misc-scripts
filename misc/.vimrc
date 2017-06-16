if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

"set term=ansi	"
if &term=="xterm-256-color" || &term=="screen-256color"
	set t_Co=256	" 256 colors
	set t_AB=^[[48;5;%dm
	set t_AF=^[[38;5;%dm
endif

if &term=="xterm" || &term=="screen"
	if &term=="screen"
		set t_Co=256
	else
		set t_Co=8
	endif
	set t_Sb=[4%dm
	set t_Sf=[3%dm
endif

" Switch syntax highlighting on, when the terminal has colors
" " Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
endif


" set color schema
colorscheme oceanblack256b

set nocompatible	" Use Vim defaults (much better!)
set bs=indent,eol,start		" allow backspacing over everything in insert mode
"set ai			" always set autoindenting on
set backup		" keep a backup file
set backupdir=~/.vimbackups/,.
au BufWritePre * let &bex = '-' . strftime("%Y%m%d-%H%M%S") . '.vimbackup'


set number		" show line numbers
set showmatch		" show matching brackets when text indicator is over them
set mat=2		" how many tenths of a second to blink when matching brackets
set wrap		" wrap lines
set ignorecase		" ignore case when searching
set smartcase		" when searching try to be smart about cases
set laststatus=2	" always show the status line
set cmdheight=2		" height of the command bar
set shortmess=a

"set expandtab		" use spaces instead of tabs

"set smarttab		" be smart when using tabs ;)
set si			" automatically inserts one extra level of indentation in some cases, and works for C-like files
" " 1 tab == 4 spaces
"set shiftwidth=4
"set tabstop=4

set viminfo='20,\"50	" read/write a .viminfo file, don't store more than 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time

" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup redhat
  autocmd!
  " In text files, always limit the width of text to 78 characters
  " autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/run/media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END
endif

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add $PWD/cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif

filetype plugin on

" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"
