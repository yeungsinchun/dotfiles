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

		-- LSP Keymaps + completion (A1) + peek (B1)
		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('UserLspKeymaps', { clear = true }),
			callback = function(ev)
				-- A1: built-in LSP completion with autotrigger (pyright + clangd)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client:supports_method('textDocument/completion') then
					vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
				end
				local opts = { buffer = ev.buf, silent = true }
				vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
					vim.tbl_extend('force', opts, { desc = 'LSP go to definition' }))
				vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
					vim.tbl_extend('force', opts, { desc = 'LSP go to declaration' }))
				-- B1: fzf-lua pickers with jump1=false (preview instead of jumping)
				vim.keymap.set('n', '<leader>gd', function()
					require('fzf-lua').lsp_definitions({ jump1 = false })
				end, vim.tbl_extend('force', opts, { desc = 'Peek definitions (fzf-lua, no jump)' }))
				vim.keymap.set('n', '<leader>gD', function()
					require('fzf-lua').lsp_declarations({ jump1 = false })
				end, vim.tbl_extend('force', opts, { desc = 'Peek declarations (fzf-lua, no jump)' }))
			end,
		})
	end,
}
