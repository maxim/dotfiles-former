call pathogen#infect()

set nocompatible
set history=1000

" Buffers
set hidden            " Keep buffer loaded if it's not displayed anywhere
set switchbuf=useopen " If buffer already open, switch to that window

" Tab
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Editing
set showmatch                  " Briefly jump to matching opening bracket
set scrolloff=3                " Offset when cursor triggers scroll
set backspace=indent,eol,start " Allow backspacing over everything in insert
filetype plugin indent on      " Enable file type detection
set autoindent
set wildmode=longest,list
set wildmenu

" Search
set incsearch            " Jump to match while typing search query
set hlsearch             " Highlight all matches
set ignorecase smartcase " Ignore case unless uppercase letters present

" Visuals
set winwidth=79
set cursorline     " Highlight cursor line
set cmdheight=2    " Height of command line
set laststatus=2   " Always show status line on last window
set numberwidth=5  " Minimum cols for line number gutter
set showtabline=2  " Always show tabline
set colorcolumn=80 " Draw vertical line on screen
set number         " Display line numbers
set showcmd        " Show command on the bottom as it's entered
" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
syntax on

" Shell
set shell=zsh
set t_ti= t_te= " Avoid clearing vim from terminal on exit

" Backup
set backup      " Use central backup dirs
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

let mapleader=","

augroup vimrcEx
  autocmd!
  autocmd FileType text setlocal textwidth=78
  
  " Jump to last cursor position unless it's invalid
  autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") |
   \   exe "normal g`\"" |
   \ endif

  " For python auto-indent with 4 spaces
  autocmd FileType python set ai sw=4 sts=4 et

  autocmd! BufRead,BufNewFile *.sass setfiletype sass

  autocmd BufRead *.mkd set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  " Indent p tags
  autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

  " Don't syntax-highlight markdown because it's often wrong
  autocmd! FileType mkd setlocal syn=off

  " Leave return key alone in command line windows since it's used
  " to run commands there
  autocmd! CmdwinEnter * :unmap <cr>
  autocmd! CmdwinLeave * :call MapCR()
augroup END

" Colors
:set t_Co=256
:color Tomorrow-Night
hi ColorColumn ctermbg=234 guibg=black
hi CursorLine cterm=NONE
"hi CursorColumn cterm=NONE ctermbg=gray guibg=gray

" Key maps
" Copy to OS X buffer with leader+y
map <leader>y "*y

" Move between splits with ctrl+hjkl
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

imap <c-c> <esc>

" Clear search buffer/highlight when hitting return
function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()
nnoremap <leader><leader> <c-^>

" Tab indents if in the beginning of line, does completion otherwise
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" Open files in directory of current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" Rename current file
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>

" Strip whitespace on write and return cursor
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType c,cpp,java,php,ruby,python
  \ autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Convert hash syntax => to :
map <leader>h :s/\:\(\S\+\)\s=>/\1:/g<CR>

set wildignore+=tmp,.git,app/assets/images,app/assets/fonts,.bundle,node_modules,public/assets,public/system
