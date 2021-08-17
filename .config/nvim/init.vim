"   ___ ___  _ __        / _|      _   _ ___  ___
"  / __/ _ \| '_ \ _____| |_ _____| | | / __|/ _ \
" | (_| (_) | | | |_____|  _|_____| |_| \__ \  __/
"  \___\___/|_| |_|     |_|        \__,_|___/\___|
"

if (has("nvim"))
  if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    echo "Downloading junegunn/vim-plug for neovim to manage plugins..."
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

set number
set mouse=a
set clipboard=unnamedplus  " use system clipboard
set history=10000    "Longer history
set undolevels=1000
let mapleader=';'
set wildignore+=*.pyc
set wildignore+=**/.git/*

call plug#begin('~/.vim/plugged')
    " essential stuff
    Plug 'tpope/vim-fugitive'  " Git for vim
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    "Plug 'tpope/vim-eunuch'  " Unix command in vim
    "Plug 'xolox/vim-misc'  " Glue to make other xolox plugins work
    Plug 'joshdick/onedark.vim'  " Nice color theme for vim
    if exists(':lua')
        Plug 'nvim-lua/popup.nvim'
        Plug 'nvim-lua/plenary.nvim'
        "Plug 'nvim-telescope/telescope.nvim', { 'on': 'Telescope' }
        Plug 'nvim-treesitter/nvim-treesitter' ", { 'commit': '47a4eadf4471af2b57fad405bd0a7b42cdf0fba6'}
        Plug 'hoob3rt/lualine.nvim'
        Plug 'akinsho/nvim-bufferline.lua'
        Plug 'Yggdroot/indentLine'
        Plug 'folke/which-key.nvim'
        Plug 'norcalli/nvim-colorizer.lua'
    endif
    "Plug 'airblade/vim-gitgutter'
    Plug 'tpope/vim-surround'  " Surround text objects with stuff
    Plug 'sbdchd/neoformat', { 'on': 'Neoformat' }  " Code formatter
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-sleuth'    " Autodetect indentation style
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-function'
    "Plug 'Yggdroot/indentLine'  " Show vertical line for indent levels
    Plug 'honza/vim-snippets'
    " experimental stuff
    Plug 'ryanoasis/vim-devicons'
    Plug 'szw/vim-maximizer', { 'on': 'MaximizerToggle' }
    "Plug 'dbeniamine/cheat.sh-vim', { 'on': 'Cheat' }
    "Plug 'kassio/neoterm', { 'on': 'Ttoggle' }
    Plug 'rhysd/vim-grammarous'
    Plug 'preservim/tagbar', { 'on': 'Tagbar' }
    Plug 'mhinz/vim-startify'  " Fancy start screen
    "Plug 'xolox/vim-notes'  " Note taking plugin in vim
    "Plug 'machakann/vim-highlightedyank'
    Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }  " Centered buffer reading
    Plug 'jiangmiao/auto-pairs'
    Plug 'psliwka/vim-smoothie'
    "Plug 'itchyny/lightline.vim'
    "Plug 'mengelbrecht/lightline-bufferline'
    Plug 'LnL7/vim-nix'           " Nix syntax
    "Plug 'lervag/vimtex'
call plug#end()

  let g:lightline = {
        \ 'component_function': {
        \   'filetype': 'MyFiletype',
        \   'fileformat': 'MyFileformat',
        \   'gitbranch': 'FugitiveHead'
        \ }, 
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
        \ },
        \ 'colorscheme': 'onedark', 
        \ 'tabline': {
        \   'left': [ ['buffers'] ],
        \   'right': [ ['close'] ]
        \ },
        \ 'component_expand': {
        \   'buffers': 'lightline#bufferline#buffers'
        \ },
        \ 'component_type': {
        \   'buffers': 'tabsel'
        \ },
  		\ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
		\ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
        \ }
  
  function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
  endfunction
  
  function! MyFileformat()
    return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
  endfunction

let g:netrw_liststyle=3
set showtabline=2
set lazyredraw

let g:netrw_banner = 0

set list lcs=tab:\|\ 

let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let g:tex_flavor = 'latex'

let $FZF_DEFAULT_OPTS='--reverse --color=dark --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef'

" somehow works in tmux now...
if has("termguicolors")
        set termguicolors
endif

syntax on

" Transparaent OneDark!
let g:one_allow_italics = 1
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799
  if (has("termguicolors"))
    set termguicolors
  endif
endif
if (has("autocmd") && !has("gui_running"))
  augroup colorset
    autocmd!
    let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
    autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white }) " `bg` will not be styled since there is no `bg` setting
  augroup END
endif
colorscheme onedark
let s:black = { "gui": "#282C34", "cterm": "235", "cterm16": "0" }
let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
call onedark#set_highlight("Normal", { "fg": s:white }) " `bg` will not be styled since there is no `bg` setting
"call onedark#set_highlight("Normal", { "fg": s:white, "bg": s:black }) " normal text
colorscheme onedark
set hidden
set list                            " show invisible characters
set listchars=tab:»·,trail:·,nbsp:· " Display extra whitespace

if exists(":lua")
    lua require'colorizer'.setup()
endif

set inccommand=split

command! -bang ProjectFiles call fzf#vim#files('~/devel', <bang>0)

nmap <leader><tab> <plug>(fzf-maps-n)
nnoremap <leader>o :ProjectFiles<CR>
nnoremap <leader><SPACE> :Files<CR>
nnoremap <leader>n :Neoformat<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>L :Lines<CR>
nnoremap <leader>r :Tags<CR>
nnoremap <leader>m :Marks<CR>
nnoremap <leader>z :Goyo<CR>

nnoremap <leader>a :Startify<CR>
nnoremap <leader>C :call CocAction('pickColor')<CR>
nnoremap <leader>d :cd %:p:h<CR>
nnoremap <leader>e :CocCommand explorer<CR>
nnoremap <leader>F :CocSearch -S 
nnoremap <leader>g :Gcd<CR>
nnoremap <leader>h :GitGutterPreviewHunk<CR>
"nnoremap <leader>j :.!nextline %:p 5<Enter>G'
nnoremap <leader>j :.!nextline de.md 5<Enter>G'
nnoremap <leader>l :Rg<CR>
nnoremap <leader>s :G<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>p :vsplit<CR> \| :terminal git push<CR>i
nnoremap <leader>N :tabnew<CR>
nnoremap <leader>k :call <SID>show_documentation()<CR>

nnoremap <leader>. :bn<CR>
nnoremap <leader>, :bp<CR>

"Y behave like D and P
nnoremap Y y$
"keep centered
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z
"Jumplist contains jumps larger 5 lines for Ctrl+o/i
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

autocmd FileType sh inoremap <leader>B if [ "$0" = "$BASH_SOURCE" ]; then<cr>fi<Esc>O
autocmd FileType python inoremap <leader>M if __name__ == "__main__":<cr>    <Esc>O


" US-intl key dead key remappings
nmap à `a|nmap á 'a
nmap ć 'c
nmap è `e|nmap é 'e
nmap ǵ 'g
nmap ì `i|nmap í 'i
nmap ḱ 'k
nmap ĺ 'l
nmap ḿ 'm
nmap ǹ `n|nmap ń 'n
nmap ò `o|nmap ó 'o
nmap ṕ 'p
nmap ŕ 'r
nmap ś 's
nmap ù `u|nmap ú 'u
nmap ǜ `v|nmap ǘ 'v
nmap ẁ `w|nmap ẃ 'w
nmap ỳ `y|nmap ý 'y
nmap ź 'z

" Faster global replace
nnoremap S :%s///gg<Left><Left><Left><Left>

if exists(':lua')
    lua require'nvim-treesitter.configs'.setup { highlight = { enable = true } }
endif

if exists(':lua')
    lua << EOF
    require('lualine').setup{ options = { theme = 'onedark', icons_enabled = true }}
    require'bufferline'.setup{}
    require'nvim-treesitter.configs'.setup { highlight = { enable = true } }
EOF

endif

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

if executable('rg')
    let g:rg_derive_root='true'
endif

autocmd CursorHold * silent call CocActionAsync('highlight')

set foldmethod=indent
set nofoldenable

nmap <leader>i  <Plug>(coc-format)
nmap <leader><F2> <Plug>(coc-rename)
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif


inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

inoremap <silent><expr> <C-l>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:neoformat_enabled_python = ['black']

set tabstop=4 shiftwidth=4 expandtab

" additional mode switching
inoremap <special> kj <ESC> 
cnoremap <special> kj <ESC> 
inoremap <special> jk <ESC>:
tnoremap <special> jk <C-\><C-n>
map <leader><leader> <Esc>/<++<Enter>"_cf>
noremap <leader>c <Esc>:silent execute "!xdg_open https://conserve.dynu.net/gitlab/jan/cheatsheets/-/blob/master/"
" maybe you want setxkbmap -option caps:escape int your (x-)profile

" Shortcutting split navigation, saving a keypress:
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>lA;

" Make accidental macro recording harder
nnoremap Q q
nnoremap q <Nop>

set tabline
set cursorline
set relativenumber
set smartcase
set ignorecase
set autoread
set scrolloff=6

set guifont=FiraCode\ Nerd\ Font\ Mono:h13
set encoding=UTF-8

set gdefault
set exrc
set secure
set title
set ruler
set colorcolumn=72
highlight ColorColumn ctermbg=233

