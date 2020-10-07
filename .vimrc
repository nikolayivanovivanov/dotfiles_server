"# On the server
"cd ~
"rm .vimrc
"wget https://raw.githubusercontent.com/nikolayivanovivanov/dotfiles_server/main/.vimrc
"mkdir ~/.vim/tmp
"rm .tmux.conf
"wget https://raw.githubusercontent.com/nikolayivanovivanov/dotfiles_server/main/.tmux.conf


set encoding=utf-8

set clipboard+=unnamed
" Are we in insert mode
"autocmd InsertEnter,InsertLeave * set cul!
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Optionally reset the cursor on start:
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END
" fallback if the above does not work
autocmd InsertEnter * set cul
autocmd InsertLeave * set nocul

let mapleader=" "

syntax on

" VERY IMPORTANT. WITHOUT THESE THE CHANGES YOU MAKE IN VIMRC WILL NOT TAKE EFFECT. THEY WILL BE STORED IN THE SESSION TOO
set ssop-=options    " do not store global and local values in a session
set ssop-=folds      " do not store folds
" Autocomplete for command mode. Example :color Tab to list autocomplete, Tab or Shift Tab to cycle list
set wildmenu
set wildmode=list:longest,full
" Create .swp files in the temporary folder to preven PhpStorm from uploading
" them to the server, or at least to save the time to configure not to do it
set directory=$HOME/.vim/tmp//
set backupdir=$HOME/.vim/tmp//
set undodir=$HOME/.vim/tmp//

highlight SpellBad cterm=underline
highlight SpellCap cterm=underline
highlight SpellLocal cterm=underline
highlight SpellRare cterm=underline

set timeoutlen=1000 ttimeoutlen=0

set wrap linebreak nolist

"set spell for text and markdown files
augroup markdownSpell
    autocmd!
    autocmd FileType markdown setlocal spell
    autocmd BufRead,BufNewFile *.md setlocal spell
    autocmd FileType text setlocal spell
    autocmd BufRead,BufNewFile *.txt setlocal spell
augroup END

function! Scratch()
    split
    noswapfile hide enew
    setlocal buftype=nofile
    setlocal bufhidden=hide
    "setlocal nobuflisted
    "lcd ~
    file scratch
endfunction
command Scratch call Scratch()

command Reset so $MYVIMRC

vnoremap * y/\V<C-R>=escape(@",'/\')<CR><CR>

" For a plugins

" Automatically install the plugin manager
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/vimfiles/plugged')

Plug 'vim-scripts/ReplaceWithRegister'

Plug 'tpope/vim-fugitive'

" Will add custom commands to try to make them common for svn too
" Add the current file
command Vadd Gwrite
" command Vwrite Gwrite
" Ignore current changes and read the file again from the VCS
command Vcheckout Gread
" Delete the current file and the corresponding Vim buffer
command Vrm Gremove
" Rename the current file and the corresponding Vim buffer
command Vmv Gmove
command Vcommit echom "Use Vstatus, - to add/remove tile, Enter to edit it, and capital C to commit"
" command Vstatus Git
command Vcs Git
command VCS Git
command Tvc Git
command Tvcm Git

" Like the Idea Annotation - to see who and when made the changes per line
command Vblame Gblame
command Vdiff Gdiff
command Vlog Glog
command VdiffToPatch :!git diff HEAD > ~/changes.patch
command VPush Gpush

" Will use Signify
" Plug 'airblade/vim-gitgutter' " for showing a git diff in the sign column
"let g:gitgutter_git_executable = 'C:\Program Files\Git\bin\git.exe'
" Can't make this work. Seems that grep is not workign properly, although I
" installed via scoop install grep on Windows
"highlight! link SignColumn LineNr
"let g:gitgutter_sign_allow_clobber = 1
"
"highlight GitGutterAdd    guifg=#009900 ctermfg=2
"highlight GitGutterChange guifg=#bbbb00 ctermfg=3
"highlight GitGutterDelete guifg=#ff2222 ctermfg=1

Plug 'mhinz/vim-signify'
" Show buffers as subtabs
Plug 'ap/vim-buftabline'

"Plug 'vim-airline/vim-airline'
Plug 'itchyny/lightline.vim'
set noshowmode
set laststatus=2


let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'

let NERDTreeShowHidden=1
" Close after opening file
let NERDTreeQuitOnOpen=1

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" The command is :FZF
command Of FZF

Plug 'mileszs/ack.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'

nmap <Leader>f <Plug>(easymotion-sn)

Plug 'pearofducks/ansible-vim'

call plug#end()


augroup vimrc_todo
    au!
    au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|todo|fixme|afixme):/
          \ containedin=.*Comment,vimCommentTitle
augroup END
hi def link MyTodo Todo

" Nerdtree
command Tp NERDTreeToggle
command Ts Tlist
command TF Ack
nnoremap <C-S-f> :Ack<space>
command Th TlistClose | NERDTreeClose

command Reload source $MYVIMRC
" Hide all tools
map <S-Esc> :TlistClose<CR>:NERDTreeClose<CR>
command CopyPath let @" = expand("%")
command CopyPathFull let @" = expand("%:p")


inoremap <C-Space> <C-n>
" to select the last char when starting visual mode reversed
" Without it it cannot select the last line of the line
set sel=inclusive

" Not tested
noremap <C-F4> <C-[>:bd<CR>
nnoremap <C-S-o>f :FZF<CR>
nnoremap <C-S-o>r :FZF<CR>
nnoremap <C-S-a> z=

nnoremap <C-S-Space>p :NERDTreeToggle<CR>
nnoremap <C-S-Space><C-S-p> :NERDTreeToggle<CR>
nnoremap <C-S-Space><Space> :Tlist<CR>
nnoremap <C-S-Space><C-S-Space> :Tlist<CR>


" try these. They work when line is wrapped. Just like on ideavim
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j


