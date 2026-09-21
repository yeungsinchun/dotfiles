local function tex_focus_vim()
  vim.fn.jobstart({ 'open', '-a', 'Terminal' }, { detach = true })
  vim.cmd.redraw()
end

local group = vim.api.nvim_create_augroup('vimtex_event_focus', { clear = true })
vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'VimtexEventViewReverse',
  callback = tex_focus_vim,
})
