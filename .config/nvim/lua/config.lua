vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  signs = true,
  update_in_insert = false,
})

-- Nerd Font icons for fzf-lua, diagnostics, etc.
pcall(require('nvim-web-devicons').setup, {
  default = true,
  strict = true,
  color_icons = true,
})

vim.lsp.config('clangd', {
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
})
vim.lsp.enable('pyright')
vim.lsp.enable('clangd')

-- LSP navigation (clangd, pyright, etc.). <C-o> jumps back in the jump list.
-- Use vim.lsp.buf.* (not fzf-lua jump1): fzf-lua's single-result jump can open the
-- target file but leave the cursor at the wrong line/column.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspKeymaps', { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
      vim.tbl_extend('force', opts, { desc = 'LSP go to definition' }))
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
      vim.tbl_extend('force', opts, { desc = 'LSP go to declaration' }))
  end,
})
