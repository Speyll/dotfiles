" Set compatibility to Vim only.
set nocompatible

"Always show current position
set ruler

" Turn on syntax highlighting.
syntax on

" Turn off modelines
set modelines=0

" Uncomment below to set the max textwidth. Use a value corresponding to the width of your screen.
set textwidth=80
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5
" Fixes common backspace problems
set backspace=indent,eol,start

" Display options
set showmode
set showcmd
set cmdheight=1

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Display different types of white spaces.
"set list
"set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Show line numbers
set relativenumber
highlight LineNr ctermfg=7

" Set status line display
set laststatus=2
hi StatusLine ctermfg=0 ctermbg=11 cterm=NONE
hi StatusLineNC ctermfg=15 ctermbg=1 cterm=NONE
hi User1 ctermfg=0 ctermbg=4
hi User2 ctermfg=NONE ctermbg=NONE
hi User3 ctermfg=0 ctermbg=6

" Section 1
set statusline=\            " Padding
set statusline+=%f          " Path to the file

" Section 2
set statusline+=\ %1*\      " Padding & switch colour
set statusline+=%y          " File type

" Switch side and color
set statusline+=\ %2*       " Change color
set statusline+=%=          " Switch to right-side

" Section 3
set statusline+=\ %3*\                                      " Padding & switch colour
set statusline+=[%{&fileencoding?&fileencoding:&encoding}]  " File encoding
set statusline+=\ [%{&fileformat}\]                         " Padding & file format
set statusline+=\ %l:%c                                     " Padding & line number

set statusline+=\ of                " of texte
set statusline+=\                   " Padding
set statusline+=%L                  " Total line
set statusline+=\                   " Padding

" Encoding
set encoding=utf-8

" Highlight matching search patterns
set hlsearch

" Enable incremental search
set incsearch

" Store info from no more than 100 files at a time, 9999 lines of text
" 100kb of data. Useful for copying large amounts of data between files.
set viminfo='100,<9999,s100
