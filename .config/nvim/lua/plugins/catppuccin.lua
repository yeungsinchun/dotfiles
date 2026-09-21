return {
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
}
