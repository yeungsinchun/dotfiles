return {
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
}
