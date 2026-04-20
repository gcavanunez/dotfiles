-- vim.opt.colorcolumn = '120'
vim.opt.cmdheight = 0
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.swapfile = false
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.termguicolors = true
vim.opt.spell = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = true
vim.o.foldlevel = 99
vim.o.foldmethod = "indent"
vim.o.foldenable = true
vim.opt.breakindent = true              -- maintain indent when wrapping indented lines
vim.opt.linebreak = true                -- wrap at word boundaries
vim.opt.list = true                     -- enable the below listchars
vim.opt.listchars = { tab = '▸ ', trail = '·' }
vim.opt.fillchars:append({ eob = ' ' }) -- remove the ~ from end of buffer
vim.opt.mouse = 'a'                     -- enable mouse for all modes
vim.opt.mousemoveevent = true           -- Allow hovering in bufferline
vim.opt.splitbelow = true
vim.opt.splitright = true
-- vim.opt.scrolloff = 999
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.clipboard = 'unnamedplus'      -- Use Linux system clipboard
vim.opt.confirm = true                 -- ask for confirmation instead of erroring
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true                -- persistent undo
vim.opt.backup = true                  -- automatically save a backup file
vim.opt.backupdir:remove('.')          -- keep backups out of the current directory
vim.opt.shortmess:append({ I = true }) -- disable the splash screen
vim.opt.wildmode =
'longest:full,full'                    -- complete the longest common match, and allow tabbing the results to fully complete them
vim.opt.completeopt = 'menuone,longest,preview'
vim.opt.signcolumn = 'yes:2'
vim.opt.showmode = false
vim.opt.autoread = true
vim.opt.updatetime = 50
-- vim.opt.updatetime = 4001  -- Set updatime to 1ms longer than the default to prevent polyglot from changing it
-- vim.opt.redrawtime = 10000 -- Allow more time for loading syntax on large files
vim.opt.exrc = true
vim.opt.secure = true
vim.opt.titlestring = '%f // nvim'

-- Neovim 0.12: floating windows now show statuslines by default.
-- Hide them globally so plugins (noice, snacks, etc.) aren't affected.
-- local float_stl = '%#WinSeparator#' .. string.rep('─', 300)
-- vim.api.nvim_create_autocmd('WinNew', {
--   callback = function()
--     vim.schedule(function()
--       for _, win in ipairs(vim.api.nvim_list_wins()) do
--         if vim.api.nvim_win_is_valid(win) then
--           local cfg = vim.api.nvim_win_get_config(win)
--           if cfg.relative ~= '' and vim.wo[win].statusline ~= float_stl then
--             vim.wo[win].statusline = float_stl
--           end
--         end
--       end
--     end)
--   end,
-- })
