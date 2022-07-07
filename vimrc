"
" Daniel's .vimrc file
"
" All macros etc. published here can be considered to be in the public domain
"
" Please feel free to share any really cool modifications with me
" (daniel@redfelineninja.org.uk)
"

" "This option has the effect of making Vim behave in a more useful way."
" I want that (and so does vimwiki). The help text strongly recommends
" that, because of the side effects, this should go right at the start
" of a vimrc file
set nocompatible

" Configure some of the plugins (also has to be before we load them).
set omnifunc=ale#completion#OmniFunc
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\    '*': ['remove_trailing_lines', 'trim_whitespace'],
\    'rust': ['rustfmt'],
\}
" Currently rust-analyzer is only available in nightly builds so this
" requires both of the following in addition to the following extra
" configuration for ALE:
"   rustup component add rust-src
"   rustup +nightly component add rust-analyzer-preview
let g:ale_rust_analyzer_executable = "/home/drt/.rustup/toolchains/nightly-aarch64-unknown-linux-gnu/bin/rust-analyzer"
let g:ale_linters = {'rust': ['cargo', 'analyzer']}

" pathogen setup (lightweight vim package manager)
" See: https://github.com/tpope/vim-pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

" Make sure the help is up-to-date (tour the pathogen modules indexing
" the help text)
Helptags

" Setup some really basic confort features (these are above and beyond what
" you find in vim-sensible).
set autowrite
set background=light
if has("gui_running") && (has("gui_gtk2") || has("gui_gtk3"))
  " Matches gnome-terminal with default theme (as of Fedora 22)
  set guifont=DejaVu\ Sans\ Mono\ 11

  " Hide the menubar and toolbar (and provide a means to restore it)
  set guioptions-=T
  set guioptions-=m
  amenu PopUp.Show/Hide\ Menubar :if &go=~#'m'<Bar>set go-=mT<Bar>else<Bar>set go+=mT<Bar>endif<CR>

  " Shortcuts to change fontsize
  nnoremap <C-Up> :silent! LargerFont<CR>
  nnoremap <C-Down> :silent! SmallerFont<CR>
endif
set mousemodel=popup
set title

" bash-like command completion until the second tab... then back to like
" vim on the third
set wildmode=longest,list,full
set wildmenu

" vimwiki setup
" Place the wiki in ~/Documents, adopt markdown syntax (and file extension)
" and automatically wrap lines at a good margin for copying things into
" e-mail.
let g:vimwiki_list = [{'path':'~/Documents/Wiki',
			\ 'path_html':'~/Documents/Wiki/html/',
			\ 'syntax': 'markdown',
			\ 'ext': '.md'}]
autocmd FileType vimwiki set tw=72
autocmd FileType vimwiki set fo=cqt

" treat C preprocessed assembler files as C
if has("autocmd")
  augroup filetype
    autocmd filetype BufRead,BufNewFile *.S set filetype=c
  augroup END
endif

" this does not actually use any auto commands but this function and its
" friends are not compiled into all vim editors (think /bin/vi on some
" GNU/Linux systems) and I cannot find the correct string from the
" docs
if has("autocmd")

  function TabSize (size)
    exe 'set noexpandtab'
    exe 'set shiftwidth=' . a:size
    exe 'set softtabstop=' . a:size
    return "Tab size = " . a:size
  endfunction

  map ,t2   :echo TabSize(2)<CR>
  map ,t3   :echo TabSize(3)<CR>
  map ,t4   :echo TabSize(4)<CR>
  map ,t8   :echo TabSize(8)<CR>
  map ,tx   :%!expand -8<CR>

  " set up the default tab size of 8
  call TabSize(8)
endif

if has("folding")
	" by default we will use fold markers to perform folding...
	set foldmethod=marker

	" ... except for XML which has an intrinsic heirarchy
	let g:xml_syntax_folding=1
	autocmd FileType xml setlocal foldmethod=syntax
endif

" Cut text down to size (C-J does not pre-join the lines)
map <C-S-J> J74\|bhcw<CR><ESC>
map <C-J> 74\|bhcw<CR><ESC>

" get lookup the API top for the current function or open its man page
map <F1> :!grep -h <cword>\( /u/thompsond/public/share/*.api<CR>
map <S-F1> :!man <cword><CR>

" open the file under the cursor with path search (ie header file)
map <F2> gf
map <S-F2> :sp<CR>gf

" use F3 to jump into and out of hex editing
map <F3> :set binary<CR>:%!xxd -c 16 <CR>
map <S-F3> :%!xxd -c 16 -r<CR>

" Reflow text in paragraph under cursor
nmap <F4> vapgq

" Tab switching
map <F6> :tabnext<CR>
map <S-F6> :tabprev<CR>

" control keys for use on make files
map <F7>   :cn<CR>
map <S-F7>   :cp<CR>

map <F8> :make<CR>

" show tagbar
nmap <F11> :TagbarToggle<CR>

" repeat the last command on the next line (F12 is Again on Sun keyboards)
map <F12> j.
map <S-F12> n.

" edit the .vimrc file
map ,vrc  :sp $HOME/.vim/vimrc<CR>
map ,vb   :sp $HOME/.vim/bundle<CR>

" use get_maintainer.pl to generate a Cc: list
map ,gcc o<ESC>!!git cc<CR>

" try to prep a patch series for release (based on contents of current
" wiki page)
map ,gr :!git release %<CR>

" Templates
map ,tr !!cat /home/drt/Documents/Wiki/release_template.md<CR>
map ,tt <ESC>1GO # <ESC>:let @"=expand("%:t:r")<CR>pkJ

" DCO shortcuts
map ,ab oAcked-by: Daniel Thompson <daniel.thompson@linaro.org><ESC>
map ,sob oSigned-off-by: Daniel Thompson <daniel.thompson@linaro.org><ESC>
map ,rb oReviewed-by: Daniel Thompson <daniel.thompson@linaro.org><ESC>
map ,tb oTested-by: Daniel Thompson <daniel.thompson@linaro.org><ESC>

" underscore based versions of vi's cw & dw
map cu c/_<CR>
map du d/_<CR>

"
" Templates
"
map ,tm !!cat ~/Projects/toys/templates/module.c
map ,tr !!cat ~/Documents/Wiki/release_template.md<CR>

"
" IDE workalike features
"

" Make sure https://github.com/Rip-Rip/clang_complete is installed...

set spell spelllang=en_gb "Enable inline spell checking"

imap <C-Space> <C-N>

" <Tab> and <S-Tab> indent and unindent code
map <Tab> :><CR>
map <S-Tab> :<<CR>

" Mash a button to fix the indentation or auto-complete (this will override the
" above for C & C++ files)
autocmd FileType c,cpp map <Tab> :py3f ~/.vim/bundle/clang-format/bin/clang-format.py<CR>
autocmd FileType c,cpp map <S-Tab> :py3f ~/.vim/bundle/clang-format/bin/clang-format.py<CR>
autocmd FileType c,cpp imap <S-Tab> <ESC>:py3f ~/.vim/bundle/clang-format/bin/clang-format.py<CR>i
autocmd FileType c,cpp imap <C-Space> <C-X><C-U>

" comment/uncomment the current statement
autocmd FileType c map //          ^i/* <ESC>/;<CR>a */<ESC>
autocmd FileType c map \\          bhh/ *[*][/]<CR>d/[/]<CR>x?[/][*]<CR>dw

" HTML tag autoclose
autocmd FileType html iabbrev </ </<C-X><C-O>
autocmd FileType html imap <C-Space> <C-X><C-O>

" Automatically update a vimwiki page (like todo.md)
autocmd FileType vimwiki map <F5> :w<CR>:!kb update %:t<CR>

" Tab closure like Firefox (causes problems with split windows)
"map <C-W> :q<CR>
"map <C-S-W> :q!<CR>

"
" Automatic issue handling
"

" Get the issue number under the cursor. An issue number contains
" alphanumerics together with # and -. The # and - characters are removed
" from the result.
"
" Examples:
"   PSE-123
"   LDTS#1744
"   bug-12345
"
" To test try:
"   :echom GetCurrentIssueText()
"
" Code heavily inspired from the words_tools.vim of Luc Hermitte
" http://hermitte.free.fr/vim/ressources/dollar_VIM/plugin/words_tools_vim.html
function! GetCurrentIssueText()
  let c = col ('.')-1
  let l = line('.')
  let ll = getline(l)
  let ll1 = strpart(ll,0,c)
  let ll1 = matchstr(ll1,'[0-9-#a-zA-Z]*$')
  if strlen(ll1) == 0
    return ll1
  else
    let ll2 = strpart(ll,c,strlen(ll)-c+1)
    let ll2 = strpart(ll2,0,match(ll2,'$\|[^0-9-#a-zA-Z]'))
    let text = ll1.ll2

    let text = substitute( text, "#", "", "g" )
    let text = substitute( text, "-", "", "g" )
    return text
  endif
endfunction

" Open IssueZilla / Bugzilla for the selected issue
function! OpenIssue( )

    let s:browser = "xdg-open"

    let s:issueText = GetCurrentIssueText( )
    let s:urlTemplate = ""
    let s:pattern = "\\(\\a\\+\\)\\(\\d\\+\\)"

    let s:prefix = substitute( s:issueText, s:pattern, "\\1", "" )
    let s:id = substitute( s:issueText, s:pattern, "\\2", "" )

    if s:prefix == "PSE"
        let s:urlTemplate = "https://projects.linaro.org/browse/PSE-%"
    elseif s:prefix == "LDTS"
        let s:urlTemplate = "https://linaro.zendesk.com/agent/tickets/%"
    elseif s:prefix == "bug"
        let s:urlTemplate = "https://bugs.96boards.org/show_bug.cgi?id=%"
    endif

    if s:urlTemplate != ""
        let s:url = substitute( s:urlTemplate, "%", s:id, "g" )
        let s:cmd = "silent !" . s:browser . " " . s:url . "&"
        execute s:cmd
    endif
endfunction

map <silent> <C-i> :call OpenIssue()<CR><C-l>
