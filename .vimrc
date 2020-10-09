"# On the server
"cd ~
"rm .vimrc
"wget https://raw.githubusercontent.com/nikolayivanovivanov/dotfiles_server/main/.vimrc
"mkdir ~/.vim/tmp
"rm .tmux.conf
"wget https://raw.githubusercontent.com/nikolayivanovivanov/dotfiles_server/main/.tmux.conf

" This did not work - switched to insert mode and pasted some symbols on scroll
set mouse=a

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
"autocmd InsertEnter * set cul
"autocmd InsertLeave * set nocul

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

" Splitting the window automatically focus the new split, but as the default
" config is splitabove and splitleft, the false impression is that we do not
" focus the new split
set splitbelow
set splitright

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

command Reload so $MYVIMRC

vnoremap * y/\V<C-R>=escape(@",'/\')<CR><CR>
" Delete mark on the current line
"https://vi.stackexchange.com/a/13986
function! Delmarks()
    let l:m = join(filter(
       \ map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)'),
       \ 'line("''".v:val) == line(".")'))
    if !empty(l:m)
        exe 'delmarks' l:m
    endif
endfunction

nnoremap <Leader>dm :<c-u>call Delmarks()<cr>




" Paragraph movement not to ignore whitespace only lines https://stackoverflow.com/a/2777488/2290045
function! ParagraphMove(delta, visual, count)
    normal m'
    normal |
    if a:visual
        normal gv
    endif

    if a:count == 0
        let limit = 1
    else
        let limit = a:count
    endif

    let i = 0
    while i < limit
        if a:delta > 0
            " first whitespace-only line following a non-whitespace character           
            let pos1 = search("\\S", "W")
            let pos2 = search("^\\s*$", "W")
            if pos1 == 0 || pos2 == 0
                let pos = search("\\%$", "W")
            endif
        elseif a:delta < 0
            " first whitespace-only line preceding a non-whitespace character           
            let pos1 = search("\\S", "bW")
            let pos2 = search("^\\s*$", "bW")
            if pos1 == 0 || pos2 == 0
                let pos = search("\\%^", "bW")
            endif
        endif
        let i += 1
    endwhile
    normal |
endfunction

nnoremap <silent> } :<C-U>call ParagraphMove( 1, 0, v:count)<CR>
onoremap <silent> } :<C-U>call ParagraphMove( 1, 0, v:count)<CR>
" vnoremap <silent> } :<C-U>call ParagraphMove( 1, 1)<CR>
nnoremap <silent> { :<C-U>call ParagraphMove(-1, 0, v:count)<CR>
onoremap <silent> { :<C-U>call ParagraphMove(-1, 0, v:count)<CR>
" vnoremap <silent> { :<C-U>call ParagraphMove(-1, 1)<CR>

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

Plug 'wsdjeg/vim-fetch'

Plug 'machakann/vim-highlightedyank'

Plug 'vim-scripts/ReplaceWithRegister'

Plug 'tpope/vim-fugitive'

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
Plug 'mileszs/ack.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'

nmap <Leader>f <Plug>(easymotion-sn)

Plug 'pearofducks/ansible-vim'

Plug 'mhinz/vim-startify'

let g:startify_session_dir = '~/.vim/sessions'
" I tried this a few times, but if I accidentally close some window or tab,
" can't restore the original layout. Better to explicitly use SSave
let g:startify_session_persistence = 0
let g:startify_session_delete_buffers = 1
let g:startify_change_to_dir = 1
let g:startify_change_to_vcs_root = 1
let g:startify_bookmarks = 1

let g:startify_lists = [
      \ { 'type': 'commands',  'header': ['   Commands']       },
      \ { 'type': 'files',     'header': ['   MRU']            },
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ ]

let g:startify_bookmarks = [ {'bh': '~/'}, {'be': '/etc'} ]

let dir_solr = '/var/lib/solr'
let g:startify_commands = [
    \ {'default': ['Default', ':source ~/.vim/sessions/devault']},
    \ {'solr': ['Solr', ':source '.dir_solr.'\ansible\ansible_musicalion_manager\.vim\sessions\default']},
    \ ]

let g:startify_session_before_save = [
    \ 'echo "Cleaning up before saving.."',
    \ 'silent! NERDTreeTabsClose',
    \ 'silent! TlistClose'
    \ ]

let g:startify_enable_special = 2
let g:startify_custom_indices = ['f','g','l','q','w','e','r','t','y','u','o','p','z','x','c','v','n','m']
let g:startify_padding_left = 3
let g:startify_custom_header = [
        \ '                                                Startify',
        \ ]


call plug#end()


augroup vimrc_todo
    au!
    au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|todo|fixme|afixme):/
          \ containedin=.*Comment,vimCommentTitle
augroup END
hi def link MyTodo Todo



inoremap <C-Space> <C-n>
" to select the last char when starting visual mode reversed
" Without it it cannot select the last line of the line
set sel=inclusive

" Not tested
noremap <C-F4> <C-[>:bd<CR>
" Does not work, because the terminals cannot make difference between
" Ctrl-char and Ctrl-Shift-char.
"nmap <C-S-O>f :FZF<CR>
"nmap <C-S-O>r :FZF<CR>
"noremap <C-S-A> z=
"noremap <C-a> ggVG
"
"nmap <C-S-Space>p :NERDTreeToggle<CR>
"nmap <C-S-Space><C-S-p> :NERDTreeToggle<CR>
"nmap <C-S-Space><Space> :Tlist<CR>
"nmap <C-S-Space><C-S-Space> :Tlist<CR>


" try these. They work when line is wrapped. Just like on ideavim
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j


" Custom actions for VIM and IdeaVim consistency. Will use programmable
" keyboard for shortcuts - max 4 chars
" MC copy (path, pathFull, r - reference, l - line, location)
command MCpath let @" = expand("%")
command MCl let @" = join([expand('%'),  line(".")], ':')
command MCpathFull let @" = expand("%:p")
" command MCr

" MA apply, action (Fix)
command MAfix z=
command MAf z=

" MT tool
command MTp NERDTreeToggle
command MTP NERDTreeToggle
command MTs Tlist
command MTf Ack
command MTh TlistClose | NERDTreeClose
command MTH TlistClose | NERDTreeClose
command MTv Git

" MV VCS (c,u,h,m - commit, update, history, menu...)
" Will add custom commands to try to make them common for svn too
" Add the current file
command MVadd Gwrite
" command Vwrite Gwrite
" Ignore current changes and read the file again from the VCS
command MVcheckout Gread
" Delete the current file and the corresponding Vim buffer
command MVrm Gremove
" Rename the current file and the corresponding Vim buffer
command MVmv Gmove
command MVcommit echom "Use Vstatus, - to add/remove tile, Enter to edit it, and capital C to commit"
" command Vstatus Git
command MV Git

" Like the Idea Annotation - to see who and when made the changes per line
command MVb Gblame
command MVa Gblame
command MVdiff Gdiff
command MVlog Glog
command MVh Glog
command MVdiffToPatch :!git diff HEAD > ~/changes.patch
command MVPush Gpush

" MF find (f or nothing - find file, s - symbol, c - class, without anything - global
" project search, u - usages if file, U - usages in project)
cnoreabbrev MFt Ack
cnoreabbrev MFU Ack
cnoreabbrev MFu Ack

" MO open
command MOf FZF
command MOr FZF
" cnoreabbrev MOb buffer
command MOb buffers

" MR rename, refactor
command MRr *Ncgn{new name}<C-[>

" Mw workspace
command MWl SLoad
command MWs SSave
command MWww set invwrap
command MWln set invrelativenumber

" MQ quit - fix the confusion between close and quit. On IdeaVim we cannot bd
" to close the buffer, but just q to close the tab - tabs vs buffers
" difference
command MQ bd
command MQw w|bd





" Copy of common file
" Common for idea and gvim
" 
" This is not comfortable on ideavim. After search it goes to the top or
" bottom most line and after the firtst move, jumps and causes me a motion
" sickness
" set scrolloff=15
set scrolloff=3
set sidescrolloff=15
"set relativenumber
"set number
" Case insensitive search by default. Use \C (capicap c) after the search term to make is case sensitive
set ic
set hls is

" Not good, because messes the idea macros
"inoremap ;; <C-[>m'A;<C-[>`'
"inoremap ,, <C-[>
"inoremap '' ''<C-[>i
"inoremap "" ""<C-[>i
"inoremap `` ``<C-[>i
"inoremap () ()<C-[>i
"inoremap {} {}<C-[>i
"inoremap {{}} {{  }}<C-[>hhi
"inoremap [] []<C-[>i
"inoremap <> <><C-[>i
"inoremap $$ $this->
"inoremap -- ->
"inoremap -] ->
"inoremap >> ->

" when this is set IDEA cannot find variables with *
"set isk+=$
" Temporarily to avoid old Ctrl s
"noremap S <nop>

" Didn't work on Idea - Start in insert mode
"set insertmode
" Remap C-W to close tab and C-Q to the VIM windows control
" Copy paste from system clipboard. Could be done with C-r" in search and command mode
"nnoremap <Leader>cy "*y
"nnoremap <Leader>cp "*p
"nnoremap <Leader>cY "+y
"nnoremap <Leader>cP "+p
"nnoremap <Leader>s ysiw
" Enter in normal mode automatically change to insert and Enter
"nnoremap <Enter> a<Enter>
"inoremap <Leader><Space> <C-[>
"inoremap <Leader>i <C-[>
"vnoremap <Leader><Space> <C-[>
"vnoremap <Leader>i <C-[>
"nnoremap <Enter> a<Enter><C-[>
"snoremap <Leader><Space> <C-[>
"snoremap <Leader>i <C-[>

nnoremap <Leader>b :ls<CR>:b<Space>

" use Backspace for Win better workflow
"nnoremap <Enter> o
"nnoremap <S-Enter> O
"noremap o <nop>
"noremap O <nop>

nmap <Space> <nop>
" If I make this to delete in normal mode, if we are in command mode and deleting text there, after we reach the beginning, the command box is closed and deleting continues in the text editor
nmap <BS> <nop>
"noremap d <nop>

" After yank in visual mode, keep the cursor to the end of the selection, but not back to the initial one.
"vmap y ygv<C-[>

" instead of <C-A>
noremap <Leader>a ggVG
" inoremap <Leader>a <C-O>gg<C-O>gH<C-O>G
cnoremap <Leader>a <C-C>gggH<C-O>G
onoremap <Leader>a <C-C>gggH<C-O>G
snoremap <Leader>a <C-C>gggH<C-O>G
xnoremap <Leader>a <C-C>ggVG

" \o add empty line below \O - above, but without moving the cursor and without entering in insert mode.
nnoremap <Leader>o m'o<C-[>`'
nnoremap <Leader>O m'O<C-[>`'

" the commentary plugin is bugged when used in macros, so use this
" Not working on HTML. Only adds // at the beginning of the line
"nnoremap gc/ m'I//<C-[>`'
"nnoremap gC/ m'^xx<C-[>`'
"nnoremap gcc m'I//<C-[>`'
"nnoremap gCc m'^xx<C-[>`'
"nnoremap gCC m'^xx<C-[>`'
"nnoremap gc# m'I#<C-[>`'
"nnoremap gC# m'^x<C-[>`'
"nnoremap gc" m'I"<C-[>`'
"nnoremap gC" m'^x<C-[>`'
"nnoremap gc; m'I;<C-[>`'
"nnoremap gC; m'^x<C-[>`'
"nnoremap gc{ m'I{*<C-[>A*}<C-[>`'
"nnoremap gC{ m'^xx<C-[>$xx<C-[>`'
"nnoremap gc< m'I<lt>!--<C-[>A--><C-[>`'
"nnoremap gC< m'^xxxx<C-[>$xxx<C-[>`'
"
"vnoremap gc/ m'o<C-[>^<C-V>`'I//<C-[>
"vnoremap gC/ ^m'o<C-[>^<C-V>`'lx<C-[>
"vnoremap gcc m'o<C-[>^<C-V>`'I//<C-[>
"vnoremap gCc ^m'o<C-[>^<C-V>`'lx<C-[>
"vnoremap gCC ^m'o<C-[>^<C-V>`'lx<C-[>
"vnoremap gc# m'o<C-[>^<C-V>`'I#<C-[>
"vnoremap gC# ^m'o<C-[>^<C-V>`'x<C-[>
"vnoremap gc" m'o<C-[>^<C-V>`'I"<C-[>
"vnoremap gC" ^m'o<C-[>^<C-V>`'x<C-[>
"vnoremap gc; m'o<C-[>^<C-V>`'I;<C-[>
"vnoremap gC; ^m'o<C-[>^<C-V>`'x<C-[>
"vnoremap gc{ m'o<C-[>i{*<C-[>`'a*}<C-[>
"vnoremap gc< m'o<C-[>i<lt>!--<C-[>`'a--><C-[>


"vnoremap <Leader>/{ I{*<C-[>
"vnoremap <Leader>/} I*}<C-[>
"nnoremap <Leader>/< I<!--<C-[>

" Delete something sendng it to the null register. Will not move the currently yanked content
"nnoremap <leader>d "_d
"vnoremap <leader>d "_d
"snoremap <leader>d "_d

nnoremap <leader>d d
vnoremap <leader>d d
snoremap <leader>d d

nnoremap d "_d
vnoremap d "_d
snoremap d "_d

nnoremap x "_x
vnoremap x "_x
snoremap x "_x

nnoremap c "_c
vnoremap c "_c
snoremap c "_c


"noremap d <nop>
"noremap x <nop>
"noremap s <nop>
"noremap p <nop>

"noremap D <nop>
"noremap X <nop>
"noremap S <nop>
"noremap P <nop>
"
"" Temporary till I get used to this
"noremap d v
"noremap x v
"noremap s v
"noremap p v
"
"noremap dd V
"noremap xx V
"noremap ss V
"noremap pp V
"
"
"noremap D v$
"noremap X v$
"noremap S v$
"noremap P v$
"
"noremap u <nop>
"noremap <C-r> <nop>

" Didn't work when copy from second char of line till the end. It placed the first char at the end
"nnoremap <C-c> dP
"vnoremap <C-c> dP
"snoremap <C-c> dP

"nnoremap <C-c><C-c> ddP

"nnoremap y dP
"vnoremap y dP
"snoremap y dP

"nnoremap <C-X> dh
"vnoremap <C-X> dh
"snoremap <C-X> dh

"nnoremap <C-x><C-x> dd

" g is used to leave the cursor after the pasted text
"nnoremap <C-V> gp
"nnoremap <C-S-V> gP

" To enagle paste with Ctrl+V enable this
"vmap <C-V> <C-R>+
"imap <C-V> <C-R>+
"cmap <C-V> <C-R>+

cmap <S-Insert> <C-R>+


vnoremap <BS> "_x
"nnoremap <BS> "_dh
"nnoremap <BS><BS> "_dd

" Move yanked to register a
" This does not work on Idea. Changing registers and thus macroses does not work
"nnoremap <Leader>ra :let @a=@0<cr>

" `] Go to the last character of the previously yanked text
"vmap y y`]
" Delete line needs separate mapping, because <Leader>d (see abbove) waits for folowing actionu
" Yank till the end if the line
"noremap Y y$
" Yank the line, but without the leading whitespace and without the new line at the end
"nnoremap <leader>yy ^y$
"nnoremap <leader>dd "_dd
"nnoremap dd "_dd
" paste the last yanked one
nnoremap <Leader>p "0p
nnoremap <Leader>P "0P
" https://superuser.com/a/656954/1130857
" List contents of all registers (that typically contain pasteable text).
"This messes the ideavim surround plugin
"nnoremap <silent> "" :registers "0123456789abcdefghijklmnopqrstuvwxyz*+.<CR>
" Bookmark current location under ', append ; at the end of line, go to bookmarked column
nnoremap <Leader>; m'A;<C-[>`'
" Delete/yank/select whole section (function, condition, while...).
" Can be used to select if section, then the else one by repeading again
" This works if you are inside or on the brackets, but not on the function name
" nnoremap <Leader>vs va{o0
vnoremap vs a{o0
" Select variable or property of property of object, including the $ char
"nnoremap <Leader>vv viwoF$
vnoremap vp iwoF$
" nnoremap <Leader>vl ^v$
vnoremap vl <C-[>^v$
vnoremap vd a`o2F`
vnoremap vj iwobb
nnoremap <Leader>yy ^y$

" Not tested Rename current
nnoremap c* *<C-o>cgn

" Go to the end of the previous selecton
" This does not work in the real vim
" nnoremap <Leader>gv gv<C-[>
" `] end of previous selection `[ beginning of previous selection
nnoremap <Leader>gv `]

" Surroind with single quotes
" For more advanced surround, use the Surround plugin
"nnoremap <Leader>' diwi'<C-C>pa'<ESC>
"vnoremap <Leader>' d<C-C>i'<C-c>pa'<ESC>

" Indeed the surround plugin works
nnoremap <Leader>' diwi'<ESC>pa'<ESC>
vnoremap <Leader>' d<C-C>i'<ESC>pa'<ESC>
nnoremap <Leader>` diwi`<ESC>pa`<ESC>
vnoremap <Leader>` d<C-C>i`<ESC>pa`<ESC>
nnoremap <Leader>" diwi"<ESC>pa"<ESC>
vnoremap <Leader>" d<C-C>i"<ESC>pa"<ESC>
nnoremap <Leader>{ diwi{<ESC>pa}<ESC>
vnoremap <Leader>{ d<C-C>i{<ESC>pa}<ESC>
nnoremap <Leader>( diwi(<ESC>pa)<ESC>
vnoremap <Leader>( d<C-C>i(<ESC>pa)<ESC>
nnoremap <Leader>[ diwi[<ESC>pa]<ESC>
vnoremap <Leader>[ d<C-C>i[<ESC>pa]<ESC>
nnoremap <Leader>} diwi{{ <ESC>pa }}<ESC>
vnoremap <Leader>} d<C-C>i{{ <ESC>pa }}<ESC>
" Now delete the surroundings
nnoremap <Leader>x' "bdi'xh"bPlx
vnoremap <Leader>x' "bdxh"bPlx
nnoremap <Leader>x` "bdi`xh"bPlx
vnoremap <Leader>x` "bdxh"bPlx
nnoremap <Leader>x" "bdi"xh"bPlx
vnoremap <Leader>x" "bdxh"bPlx
nnoremap <Leader>x{ "bdi{xh"bPlx
vnoremap <Leader>x{ "bdxh"bPlx
nnoremap <Leader>x( "bdi(xh"bPlx
vnoremap <Leader>x( "bdxh"bPlx
nnoremap <Leader>x[ "bdi[xh"bPlx
vnoremap <Leader>x[ "bdxh"bPlx

" Disable highlighting of search till the next search
" Disable highlighting of search till the next search
"nnoremap <C-C> :noh<CR><C-C>
"vnoremap <C-C> :noh<CR><C-C>

" https://stackoverflow.com/a/3691326/2290045
" vnoremap <ESC> :noh<CR><ESC>
" nnoremap <ESC> :noh<CR><ESC>
vnoremap <Leader><ESC> :noh<CR><ESC>
nnoremap <Leader><ESC> :noh<CR><ESC>

"nnoremap <C-[> :noh<CR><C-[>
"vnoremap <C-[> :noh<CR><C-[>
" Disable Escape, because it closes the IDE popup windows (diff, find...). Use Ctrl-c to escape
"vnoremap <ESC> <NOP>
" Slows down the k letter. Use the built in C-c or C-[
"inoremap kj <C-[>
"vnoremap kj <C-[>
"snoremap kj <C-[>
" Use AHK to make sure CapsLock is off when entering in normal mode
"inoremap <C-I> <C-[>
"vnoremap <C-I> <C-[>
"snoremap <C-I> <C-[>
" Search for the selected text. Based on https://vim.fandom.com/wiki/Search_for_visually_selected_text
" but as the default register " didn't work in PhpStorm, I used the first one 0
" This did't really work well for me. I'll use the built in Idea Ctrl /
" Or even better <C-Q> (it is C-V, but msvimc makes is paste) to enter visual mode, make selection down till where you want to comment, type what you want (//) ,Esc
"vnoremap // y/\V<C-R>0<CR>
" too difficutl. Let the ide shortcuts for this
"nmap * :action HighlightUsagesInFile<CR>
" Disable sound
set visualbell
set noerrorbells
" Disable arrow keys till you learn. This does not really work on Idea, but I'll leave it here for easy port to the real VIM
"noremap <Up> <nop>
"noremap <Down> <nop>
"noremap <Left> <nop>
"noremap <Right> <nop>

nnoremap <Up> k
nnoremap <Down> j
nnoremap <Left> h
nnoremap <Right> l

vnoremap <Up> k
vnoremap <Down> j
vnoremap <Left> h
vnoremap <Right> l

snoremap <Up> k
snoremap <Down> j
snoremap <Left> h
snoremap <Right> l

nnoremap <silent> <C-Right> w
nnoremap <silent> <C-Left> b
" When selection from left to right, the default Windows behavior is to select till the end of the word, but not till the beginning of the next one.
vnoremap <silent> <C-Right> e
vnoremap <silent> <C-Left> b
"noremap <silent> <C-Down> 5j
"noremap <silent> <C-Up> 5k
noremap <PageDown> 15j
noremap <PageUp> 15k

" Use the arrows only
"noremap h <nop>
"noremap j <nop>
"noremap k <nop>
"noremap l <nop>


" toggle X to -x
"nnoremap <Leader>uu dli-<ESC>pg~l
nnoremap <Leader>uu dli-<ESC>pg~<Right>
" toggle -x to X
"nnoremap <Leader>ua xg~
nnoremap <Leader>ua xg~<Right>

" Same shortcut is used on tmux custim config. Use <Leader>a to select all
" CTRL-A is Select all
"noremap <C-A> gggH<C-O>G
"inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
"cnoremap <C-A> <C-[>gggH<C-O>G
"onoremap <C-A> <C-[>gggH<C-O>G
"snoremap <C-A> <C-[>gggH<C-O>G
"xnoremap <C-A> <C-[>ggVG

"nnoremap <Enter> o
"nnoremap <Enter> i<CR>

"nnoremap <S-Enter> o
" Enter to add new line, but not to switch to insert mode
" nnoremap <Enter> o<C-[>
" nnoremap <S-Enter> O<C-[>
"tmp fix - o does not indent the new line on IDEA
"nnoremap <Enter> A<CR><C-[>
"nnoremap <S-Enter> ^kA<CR><C-[>

"nnoremap o $
"nnoremap u ^

" Can't remap kHome. Does not work even in gVim
"nnoremap <kHome> 0
"vnoremap <kHome> 0
"snoremap <kHome> 0
nnoremap <Home> ^
vnoremap <Home> ^
snoremap <Home> ^
nnoremap <End> $
vnoremap <End> $
snoremap <End> $

" These never worked with my code
":noremap [[ [m
":noremap ]] ]m

command RemoveWhiteSpaces :%s/\s\+$//e


" Din't work Make quick selection for IDEA usage without vim
"nnoremap <silent> <C-F2> vi
"nnoremap <silent> <C-S-F2> va



" This is when autoshift is enablen for the Plank keyboard

"noremap H h
"noremap J j
"noremap K k
"noremap L l
" inoremap <S-Ins> <C-[>:echom 'Use "C-r +".Cant paste in input mode'


"inoremap <S-Ins> <C-[>pa






