-- Space is my leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Quickly clear search highlighting.
-- vim.keymap.set('n', '<leader>k', ':nohlsearch<CR>')
vim.keymap.set('n', '<leader>k', '<cmd>nohlsearch<CR>')

-- local change_font_script = [[
--   # FILE=$(readlink -f $HOME/.config/alacritty/alacritty.toml)
--   FILE=$(readlink -f $HOME/dotfiles/wezterm/wezterm.lua)

--   # Check if the resolved file exists
--   if [ ! -f "$FILE" ]; then
--       echo "Error: The file '$FILE' does not exist."
--       exit 1
--   fi

--   # Check if the file contains 'size = 16'
--   # if grep -q 'size = 16' "$FILE"; then
--   #    echo "Changing 'size = 16' to 'size = 22'"
--   #    sed -i '' 's/size = 16/size = 22/g' "$FILE"
--   # Check if the file contains 'size = 22'
--   # elif grep -q 'size = 22' "$FILE"; then
--   #    echo "Changing 'size = 22' to 'size = 16'"
--   #    sed -i '' 's/size = 22/size = 16/g' "$FILE"
--   # else
--   #    echo "No changes made. The file does not contain 'size = 16' or 'size = 22'."
--   # fi

--   # Check if the file contains 'config.font_size = 16'
--   if grep -q 'config.font_size = 16' "$FILE"; then
--       echo "Changing 'config.font_size = 16' to 'config.font_size = 20'"
--       sed -i '' 's/config.font_size = 16/config.font_size = 20/g' "$FILE"
--   # Check if the file contains 'config.font_size = 22'
--   elif grep -q 'config.font_size = 20' "$FILE"; then
--       echo "Changing 'config.font_size = 20' to 'config.font_size = 12'"
--       sed -i '' 's/config.font_size = 20/config.font_size = 14/g' "$FILE"
--   elif grep -q 'config.font_size = 14' "$FILE"; then
--       echo "Changing 'config.font_size = 14' to 'config.font_size = 16'"
--       sed -i '' 's/config.font_size = 14/config.font_size = 16/g' "$FILE"
--   else
--       echo "No changes made. The file does not contain 'config.font_size = 16' or 'config.font_size = 22'."
--   fi
-- ]]
-- Quickly clear search highlighting.
-- vim.keymap.set('n', '<leader>KK', function()
--   -- vim.cmd('silent !~/change_font_size.sh')
--   -- vim.cmd('silent !zsh -ic "toggle_font"')
--   vim.fn.system('bash -c ' .. vim.fn.shellescape(change_font_script))
-- end, { desc = 'Change font size in Alacritty config', noremap = true, silent = false })

local function change_wezterm_font_size()
  local file_path = vim.fn.expand('~/dotfiles/wezterm/wezterm.lua')

  -- Check if file exists
  if vim.fn.filereadable(file_path) == 0 then
    vim.notify("Error: The file '" .. file_path .. "' does not exist.", vim.log.levels.ERROR)
    return
  end

  -- Read file content
  local content = vim.fn.readfile(file_path)
  local content_str = table.concat(content, '\n')

  -- Define the font size transitions
  local size_changes = {
    [16] = 20,
    [20] = 14,
    [14] = 16,
  }

  -- Find current font size with more permissive pattern
  local current_size = string.match(content_str, 'config%.font_size%s*=%s*(%d+)')

  -- Debug output
  if not current_size then
    vim.notify('No font size found in config', vim.log.levels.WARN)
    -- Print a portion of the content for debugging
    local preview = string.sub(content_str, 1, 500)
    vim.notify('File content preview: ' .. preview, vim.log.levels.DEBUG)
    return
  end

  current_size = tonumber(current_size)
  -- vim.notify('Found font size: ' .. tostring(current_size))

  if current_size and size_changes[current_size] then
    local new_size = size_changes[current_size]
    local new_content = string.gsub(content_str, 'config%.font_size%s*=%s*' .. current_size,
      'config.font_size = ' .. new_size)

    -- Write changes back to file
    local file = io.open(file_path, 'w')
    if file then
      file:write(new_content)
      file:close()
      vim.notify(string.format('Changed font size from %d to %d', current_size, new_size))
    else
      vim.notify('Failed to write to file', vim.log.levels.ERROR)
    end
  else
    vim.notify('No valid font size found for transition', vim.log.levels.WARN)
  end
end

-- Font size toggle keybinding
vim.keymap.set('n', '<leader>KK', change_wezterm_font_size,
  { desc = 'Change font size in Wezterm config', noremap = true, silent = false })

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
vim.keymap.set('n', '<c-s>', '<cmd>write<CR>')

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

vim.keymap.set('n', '<leader>tb', '<cmd>DapToggleBreakpoint<CR>', { desc = 'Add breakpoint at line' })
vim.keymap.set('n', '<leader>tr', '<cmd>DapContinue<CR>', { desc = 'Run or continue the debugger' })
vim.keymap.set('n', '<leader>kd', '<cmd>NoiceDismiss<CR>', { desc = 'Dismiss Noice' })
-- https://github.com/alextricity25/nvim_weekly_plugin_configs/blob/main/lua/keymappings.lua
local function visual_cursors_with_delay()
  -- Execute the vm-visual-cursors command.
  vim.cmd('silent! execute "normal! \\<Plug>(VM-Visual-Cursors)"')
  -- Introduce delay via VimScript's 'sleep' (set to 500 milliseconds here).
  vim.cmd('sleep 200m')
  -- Press 'A' in normal mode after the delay.
  vim.cmd('silent! execute "normal! A"')
end
vim.keymap.set('n', '<leader>ma', '<Plug>(VM-Select-All)<Tab>', { desc = 'Select All' })
vim.keymap.set('n', '<leader>mr', '<Plug>(VM-Start-Regex-Search)', { desc = 'Start Regex Search' })
vim.keymap.set('n', '<leader>mp', '<Plug>(VM-Add-Cursor-At-Pos)', { desc = 'Add Cursor At Pos' })
vim.keymap.set('v', '<leader>mv', visual_cursors_with_delay, { desc = 'Visual Cursors' })
vim.keymap.set('n', '<leader>mo', '<Plug>(VM-Toggle-Mappings)', { desc = 'Toggle Mapping' })
