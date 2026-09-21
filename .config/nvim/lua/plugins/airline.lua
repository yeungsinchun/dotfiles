return {
	'vim-airline/vim-airline',
	lazy = false,
	init = function()
		vim.g.airline_powerline_fonts = 1
	end,
	config = function()
		-- Avoid emoji glyphs that often render as double-width in terminals.
		vim.g.airline_symbols.crypt = 'cr'
	end,
}
