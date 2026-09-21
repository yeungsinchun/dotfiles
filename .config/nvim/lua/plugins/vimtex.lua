return {
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
}
