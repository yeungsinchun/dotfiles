-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require('lazy').setup({
  spec = 'plugins',
  install = { colorscheme = { 'catppuccin' } },
  rocks = {
    enabled = false,
  },
})

require('config')

local function plain_syntax()
  for _, group in ipairs({
    'Comment',
    'Conditional',
    'Repeat',
    'Statement',
    'luaCond',
    'luaCondElse',
    'luaStatement',
    'luaRepeat',
    'luaFor',
    'luaFunction',
  }) do
    vim.api.nvim_set_hl(0, group, { link = 'Normal', default = false })
  end
end

vim.api.nvim_create_autocmd('ColorScheme', { callback = plain_syntax })
vim.api.nvim_create_autocmd('Syntax', { callback = plain_syntax })
plain_syntax()

-- Editor settings
vim.o.number = true
vim.o.mouse = 'a' -- enable mouse in all modes (normal, visual, insert, command-line)
vim.o.tabstop = 4 -- display width of a tab character
vim.o.shiftwidth = 4 -- spaces used for >>, <<, and auto-indent
vim.o.backupcopy = 'yes' -- copy the file before overwriting (needed on macOS for tools that replace files)
vim.o.termguicolors = true
vim.o.relativenumber = true
vim.o.conceallevel = 1 -- hide markup (e.g. LaTeX \\item) when not on that line; 2 hides more aggressively

-- vim.g.python3_prog_host = '/Library/Frameworks/Python.framework/Versions/3.10/bin/python3'
-- vim.g.tex_flavor = 'latex'

vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter' }, {
  pattern = '*',
  callback = function()
    vim.o.scrolloff = math.floor(vim.fn.winheight(0) / 4)
  end,
})

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- autocmd FileType plaintex,tex,context setlocal indentexpr=

vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tex',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { 'nl', 'en_us' }
  end,
})

vim.keymap.set('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u')
vim.cmd('hi clear Conceal')

vim.keymap.set('n', '<localleader>v', '<plug>(vimtex-view)')

-- OCaml indentation
vim.opt.rtp:prepend('/Users/sinchunyeung/.opam/default/share/ocp-indent/vim')
