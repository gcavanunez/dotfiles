return {
    "mbbill/undotree",
    -- lazy = false,
    -- config = function()
    --     vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    -- end
    keys = {
        { '<Leader>u', '<Cmd>UndotreeToggle<CR>', desc = 'Toggle undotree window', mode = 'n', silent = true },
    },
    -- config = function()
    --     vim.g.undotree_WindowLayout = 4
    --     vim.g.undotree_SetFocusWhenToggle = 1
    --     vim.g.undotree_SplitWidth = 60
    --     vim.g.Undotree_CustomMap = function()
    --         vim.keymap.set('n', 'k', '<Plug>UndotreeGoNextState', { buffer = true, silent = true })
    --         vim.keymap.set('n', 'j', '<Plug>UndotreeGoPreviousState', { buffer = true, silent = true })
    --         vim.keymap.set('n', '<Esc>', '<Plug>UndotreeClose', { buffer = true, silent = true })
    --     end
    -- end,
}
