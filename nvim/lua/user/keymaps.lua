-- Space is my leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Quickly clear search highlighting.
-- vim.keymap.set('n', '<leader>k', ':nohlsearch<CR>')
vim.keymap.set('n', '<leader>k', '<cmd>nohlsearch<CR>')

local change_font_script = [[
  FILE=$(readlink -f $HOME/.config/alacritty/alacritty.toml)

# Check if the resolved file exists
  if [ ! -f "$FILE" ]; then
      echo "Error: The file '$FILE' does not exist."
      exit 1
  fi

    # Check if the file contains 'size = 16'
    if grep -q 'size = 16' "$FILE"; then
        echo "Changing 'size = 16' to 'size = 22'"
        sed -i '' 's/size = 16/size = 22/g' "$FILE"
    # Check if the file contains 'size = 22'
    elif grep -q 'size = 22' "$FILE"; then
        echo "Changing 'size = 22' to 'size = 16'"
        sed -i '' 's/size = 22/size = 16/g' "$FILE"
    else
        echo "No changes made. The file does not contain 'size = 16' or 'size = 22'."
    fi
]]
-- Quickly clear search highlighting.
vim.keymap.set('n', '<leader>KK', function()
  -- vim.cmd('silent !~/change_font_size.sh')
  -- vim.cmd('silent !zsh -ic "toggle_font"')
  vim.fn.system('bash -c ' .. vim.fn.shellescape(change_font_script))
end, { desc = 'Change font size in Alacritty config', noremap = true, silent = false })

-- Close all open buffers.
-- vim.keymap.set('n', '<leader>Q', ':bufdo bdelete<CR>')

-- Close all open buffers.
vim.keymap.set('n', '<leader>w', '<cmd>close<CR>')

-- Allow gf to open non-existent files.
vim.keymap.set('', 'gf', ':edit <cfile><CR>')

-- Reselect visual selection after indenting.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
-- vim.keymap.set('v', 'p', '\\_dP')

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
vim.keymap.set('v', 'y', 'myy`y')
vim.keymap.set('v', 'Y', 'myY`y')

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Paste replace visual selection without copying it.
-- vim.keymap.set('v', 'p', '"_dP', { noremap = true })
-- primeagen
-- vim.keymap.set("x", "<leader>p", [["_dP]])
-- this is way better
vim.keymap.set({ 'n', 'x' }, '<leader>p', [["0p]], { desc = 'paste from yank register' })

-- Easy insertion of a trailing ; or , from insert mode.
vim.keymap.set('i', ';;', '<Esc>A;<Esc>')
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('i', ',,', '<Esc>A,<Esc>')

-- Open the current file in the default program (on Mac this should just be just `open`).
vim.keymap.set('n', '<leader>x', ':!xdg-open %<cr><cr>')

-- Disable annoying command line thing.
vim.keymap.set('n', 'q:', ':q<CR>')

-- Resize with arrows.
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>')
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>')
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>')

-- vim.keymap.set('n', ']g', vim.diagnostic.goto_next)
vim.keymap.set('n', ']g', function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Go to next diagnostic warning' })
vim.keymap.set('n', '[d', function()
  vim.diagnostic.goto_next()
end, opts)
vim.keymap.set('n', ']d', function()
  vim.diagnostic.goto_prev()
end, opts)

-- vim.keymap.set('n', '<leader><c-s>', ':noa w<CR>')
vim.keymap.set('n', '<leader><c-s>', '<cmd>noautocmd write<CR>')

-- vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
-- Move text up and down
vim.keymap.set('i', '<A-j>', '<Esc>:move .+1<CR>==gi')
vim.keymap.set('i', '<A-k>', '<Esc>:move .-2<CR>==gi')
vim.keymap.set('n', '<A-j>', ':move .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':move .-2<CR>==')
vim.keymap.set('v', '<A-j>', ":move '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":move '<-2<CR>gv=gv")

-- https://www.lazyvim.org/configuration/tips
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })

-- Move down and center.
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>kr', ':%s//', { noremap = true, silent = false })

local toggle_surrounding_quote_style = function()
  local current_line = vim.fn.line('.')
  local next_single_quote = vim.fn.searchpos("'", 'cn')
  local next_double_quote = vim.fn.searchpos('"', 'cn')
  local next_backtick = vim.fn.searchpos('`', 'cn')

  if next_single_quote[1] ~= current_line then
    next_single_quote = false
  end
  if next_double_quote[1] ~= current_line then
    next_double_quote = false
  end
  if next_backtick[1] ~= current_line then
    next_backtick = false
  end

  if next_single_quote == false and next_double_quote == false and next_backtick == false then
    print('Could not find quotes or backticks on current line!')
  else
    -- Determine which quote type is the closest
    local closest = nil
    if next_single_quote then
      closest = next_single_quote
    end
    if next_double_quote and (not closest or next_double_quote[2] < closest[2]) then
      closest = next_double_quote
    end
    if next_backtick and (not closest or next_backtick[2] < closest[2]) then
      closest = next_backtick
    end

    if closest == next_single_quote then
      vim.cmd.normal([[macs'"a]])
    elseif closest == next_double_quote then
      vim.cmd.normal([[macs"`a]])
    elseif closest == next_backtick then
      vim.cmd.normal([[macs`'a]])
    end
  end
end
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { noremap = true })
vim.keymap.set('t', 'jk', [[<C-\><C-n>]], { noremap = true })
vim.keymap.set('n', "<Leader>'", toggle_surrounding_quote_style)

vim.keymap.set('n', '<leader>kd', '<cmd>NoiceDismiss<CR>', { desc = 'Dismiss Noice' })
