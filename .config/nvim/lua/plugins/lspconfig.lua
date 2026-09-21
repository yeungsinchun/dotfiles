return {
	'neovim/nvim-lspconfig',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		-- Diagnostics
		vim.diagnostic.config({
			virtual_text = true,
			underline = true,
			signs = true,
			update_in_insert = false,
		})

		-- Devicons setup (safe fallback via pcall)
		pcall(require('nvim-web-devicons').setup, {
			default = true,
			strict = true,
			color_icons = true,
		})

		-- Language Servers (Neovim 0.11+ native LSP API)
		vim.lsp.config('clangd', {
			filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
		})
		vim.lsp.enable('pyright')
		vim.lsp.enable('clangd')

		-- LSP Keymaps
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
	end,
}
