" This is a comment

set mouse=    " Disable mouse COMPLETELY!
set scrolloff=5 " Leave 5 lines above/below cursor

set number relativenumber " Turn hybrid line numbers on 

" Hide the --INSERT-- prompt and its relatives, as they are already
" present in the status line
set noshowmode

set colorcolumn=80 " Visual indicator for good coding style

autocmd FileType * set formatoptions-=o formatoptions-=r formatoptions+=c " No
" comment inserted when pressing Enter in Insert mode / pressing o/O in normal
" mode, but auto-wrap comments

set wrap linebreak

set tabstop=4 shiftwidth=4 expandtab " Make the tab key use SPACES to jump to
" next tab stop
set autoindent " Maintain indent when a new line is inserted

set noswapfile " No swap file

colorscheme codedark

" *** PLUGINS ***

" vim-plug
call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes
    
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'preservim/nerdtree'
    Plug 'mbbill/undotree'
    
call plug#end()
" end vim-plug


" lua call for lualine config (custom file)
lua require('nvim-lualine-config')

let g:undotree_SetFocusWhenToggle = 1

" *** MAPPINGS ***


set timeout timeoutlen=750    " ms
let mapleader="\<space>"    " space as leader key


" Use gx to open URL
nnoremap <silent> gx :!start "" "<cWORD>"<cr><cr>

" Map k to gk, j to gj (go to previous display line) except if count given
" (still allows for a count with wrapped lines)
if exists('g:vscode')
    nmap <expr> k (v:count == 0 ? 'gk' : 'k')
    nmap <expr> j (v:count == 0 ? 'gj' : 'j')
else
    nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
    nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
endif

" Map key chord 'jk' to <Esc> (insert mode)
let g:esc_j_lasttime = 0
let g:esc_k_lasttime = 0
function! JKescape(key)
	if a:key=='j' | let g:esc_j_lasttime = reltimefloat(reltime()) | endif
	if a:key=='k' | let g:esc_k_lasttime = reltimefloat(reltime()) | endif
	let l:timediff = abs(g:esc_j_lasttime - g:esc_k_lasttime)
	return (l:timediff <= 0.07 && l:timediff >=0.001) ? "\b\e" : a:key " \b\e for <backspace><esc>
endfunction
inoremap <expr> j JKescape('j')
inoremap <expr> k JKescape('k')

" Remap Ctrl-C to escape, allows for autocompletion as well as InsertLeave
inoremap <C-c> <esc>

" Remap leader to no-op (annoying if not done)
nnoremap <leader> <nop>
vnoremap <leader> <nop>



" <leader>te for TabEdit
nnoremap <leader>te :tabe<space>

" <leader>tn for TabNew
if exists('g:vscode') " need to use map here for VSCode
    nmap <leader>tn :tabnew<cr>
else
    nnoremap <leader>tn :tabnew<cr>
endif
" <leader>tm for TabMove
nnoremap <leader>tm :tabm<space>

" <leader>h for Nohls
nnoremap <leader>h :nohls<cr>


" <leader>nt for NERDTree
nnoremap <silent> <leader>nt :silent<space>NERDTreeMirror<space><bar><space>:NERDTreeFocus<cr>
" <leader>ut for UndoTree
nnoremap <leader>ut :UndotreeShow<cr>
" <leader>mk for MaKe (no enter)
nnoremap <leader>mk :make


" <leader>p in VISUAL mode pastes without replacing the paste register ( "_ is black hole register, P is paste before cursor)
xnoremap <leader>p "_dP
" <leader>p in VISUAL mode pastes from system register without replacing it
xnoremap <leader>P "_d"+P

" <leader>(p|P) in NORMAL mode pastes from system register
nnoremap <leader>p "+p
nnoremap <leader>P "+P

" Yank (forwards/backwards) into clipboard (xnoremap->visual, vnoremap->visual/select)
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y

" Delete into black hole (do not replace paste register)
nnoremap <leader>d "_d
vnoremap <leader>d "_d
nnoremap <leader>c "_c
nnoremap <leader>x "_x
nnoremap <leader>s "_s
