" Set compatibility to Vim only.
set nocompatible

" Colors
syntax enable
set background=dark
colorscheme solarized

" Always show current position
set ruler

" Turn off modelines
set modelines=0

" Tabs and widths
set formatoptions=tcqrn1
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
"set textwidth=80

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Indenting
set smartindent
set autoindent

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Fixes common backspace problems
set backspace=indent,eol,start

" Display options
set showmode
set showcmd
set cmdheight=1

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Line numbers
set nu
set relativenumber
"set cursorline

" Encoding
set encoding=utf-8

" Highlight matching search patterns
set hlsearch

" Enable incremental search
set incsearch

" Enable mouse support
set mouse=a

" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5

" Clipboard between vim and everywhere else
set clipboard=unnamedplus

" Store info from no more than 100 files at a time, 9999 lines of text
" 100kb of data. Useful for copying large amounts of data between files.
set viminfo='100,<9999,s100

" Display different types of white spaces.
"set list
"set listchars=tab:›\ ,trail:•,extends:#,nbsp:.