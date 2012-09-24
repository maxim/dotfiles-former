call pathogen#infect()

set nocompatible
set hidden
set history=1000
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch
set ignorecase smartcase
set cursorline
set cmdheight=2
set switchbuf=useopen
set numberwidth=5
set showtabline=2
set winwidth=79
set shell=zsh
set t_ti= t_te=
set scrolloff=3
set colorcolumn=80
set number
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backspace=indent,eol,start
set showcmd
syntax on
filetype plugin indent on
set wildmode=longest,list
set wildmenu
let mapleader=","

augroup vimrcEx
  autocmd!
  autocmd FileType text setlocal textwidth=78
  
  autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") |
   \   exe "normal g`\"" |
   \ endif

  autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass,cucumber set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et

  autocmd! BufRead,BufNewFile *.sass setfiletype sass

  autocmd BufRead *.mkd set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd' | endif

  autocmd! FileType mkd setlocal syn=off

  autocmd! CmdwinEnter * :unmap <cr>
  autocmd! CmdwinLeave * :call MapCR()
augroup END

:set t_Co=256
:set background=dark
colorscheme ir_black
hi ColorColumn ctermbg=black guibg=black
hi CursorLine   cterm=NONE ctermbg=black guibg=black 
hi CursorColumn cterm=NONE ctermbg=black guibg=black 

map <leader>y "*y

nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

imap <c-c> <esc>

function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()
nnoremap <leader><leader> <c-^>

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

map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

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

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

map <leader>h :s/\:\(\S\+\)\s=>/\1:/g<CR>
set noesckeys

let g:ctrlp_root_markers = ['.ctrlp']
set wildignore+=*/tmp/*
