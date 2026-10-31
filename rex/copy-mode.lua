-- A bare, read-only snapshot viewer; no user config, plugins, or clipboard reads.
vim.opt.modeline = false
vim.opt.exrc = false
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.clipboard = ''
vim.opt.mouse = ''
vim.opt.wrap = false
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.showmode = true
vim.opt.laststatus = 2
vim.opt.statusline = ' COPY SNAPSHOT | v/V/C-v select | y/Enter copy | q/Esc cancel %=%l/%L '

local function cancel()
  vim.cmd('qa!')
end
for _, key in ipairs({ 'q', '<Esc>', '<C-c>' }) do
  vim.keymap.set({ 'n', 'x' }, key, cancel, { silent = true })
end
vim.keymap.set('n', '<CR>', 'yy', { remap = false })
vim.keymap.set('x', '<CR>', 'y', { remap = false })

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.bo.buftype = 'nofile'
    vim.bo.bufhidden = 'wipe'
    vim.bo.readonly = true
    vim.bo.modifiable = false
    vim.cmd('normal! G0zb')
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    if vim.v.event.operator ~= 'y' then return end
    local lines = vim.deepcopy(vim.v.event.regcontents)
    if vim.v.event.regtype == 'V' then lines[#lines + 1] = '' end
    -- OSC52 goes through Rex to the viewing app, including for remote hosts.
    -- Do not query the clipboard or depend on remote pbcopy/Wayland providers.
    require('vim.ui.clipboard.osc52').copy('+')(lines)
    -- Let the TUI flush its clipboard write before closing the terminal pane.
    vim.defer_fn(cancel, 150)
  end,
})
