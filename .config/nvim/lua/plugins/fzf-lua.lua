return {
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
		keymap = {
			builtin = {
				["<S-j>"] = "preview-down",
				["<S-k>"] = "preview-up",
				[true] = true,
			},
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
}
