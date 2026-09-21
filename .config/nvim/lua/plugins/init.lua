return {
	{
		'lervag/vimtex',
		ft = { 'tex', 'plaintex' },
		init = function()
			vim.g.vimtex_view_method = 'skim'
			vim.g.vimtex_view_skim_sync = 1
			vim.g.vimtex_view_skim_activate = 1
			vim.g.tex_conceal = 'abdmg'
			vim.g.vimtex_compiler_latexmk = {
				options = {
					'-shell-escape',
					'-verbose',
					'-file-line-error',
					'-synctex=1',
					'-interaction=nonstopmode',
				},
			}
		end,
	},

	{
		'SirVer/ultisnips',
		ft = { 'tex', 'plaintex' },
		init = function()
			vim.g.UltiSnipsExpandTrigger = '<tab>'
			vim.g.UltiSnipsJumpForwardTrigger = '<tab>'
			vim.g.UltiSnipsJumpBackwardTrigger = '<S-Tab>'
			vim.g.UltiSnipsSnippetDirectories = { vim.fn.expand('$HOME') .. '/.config/nvim/UltiSnips' }
		end,
		keys = {
			{
				'<leader>u',
				function()
					vim.cmd('call UltiSnips#RefreshSnippets()')
				end,
				desc = 'Refresh UltiSnips',
			},
		},
	},

	{
		'vim-airline/vim-airline',
		lazy = false,
		init = function()
			vim.g.airline_powerline_fonts = 1
		end,
		config = function()
			-- Avoid emoji glyphs that often render as double-width in terminals.
			vim.g.airline_symbols.crypt = 'cr'
		end,
	},

	{
		'catppuccin/nvim',
		name = 'catppuccin',
		lazy = false,
		priority = 1000,
		opts = {
			auto_integrations = false,
			styles = {
				comments = {},
			},
		},
		config = function(_, opts)
			require('catppuccin').setup(opts)
			vim.cmd.colorscheme('catppuccin')
		end,
	},

	{
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
	},

	{
		'ibhagwan/fzf-lua',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			files = { 
				fd_opts = "--color=never --type f --hidden --no-ignore --exclude .git",
			},
			grep = { 
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --no-ignore -g !.git",
			},
			defaults = {
				file_icons = true,
				color_icons = true,
				git_icons = true,
			},
		},
		keys = {
			{ '<C-p>', function() require('fzf-lua').files() end, desc = 'Fzf files' },
			{ '<C-l>', function() require('fzf-lua').live_grep() end, desc = 'Fzf live grep' },
			{ '<C-\\>', function() require('fzf-lua').buffers() end, desc = 'Fzf buffers' },
			{ '<C-g>', function() require('fzf-lua').grep_project() end, desc = 'Fzf grep project' },
			{ '<C-k>', function() require('fzf-lua').builtin() end, desc = 'Fzf builtin' },
			{ '<F1>', function() require('fzf-lua').help_tags() end, desc = 'Fzf help' },
		},
	}}
