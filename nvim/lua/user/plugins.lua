-- Bootstrap Lazy
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Color scheme
  { import = 'user.themes.tokyonight' },
  { import = 'user.themes.poimandres' },
  { import = 'user.themes.nord' },
  { import = 'user.themes.vesper' },
  { import = 'user.themes.mellow' },
  { import = 'user.themes.catppuccin' },
  -- { import = 'user.themes.noirbuddy' },
  -- Commenting support.
  { import = 'user.plugins.vim-commentary' },

  -- Add, change, and delete surrounding text.
  { 'tpope/vim-surround' },

  -- https://github.com/mg979/vim-visual-multi
  { 'mg979/vim-visual-multi' },

  -- Useful commands like :Rename and :SudoWrite.
  { 'tpope/vim-eunuch' },

  -- Pairs of handy bracket mappings, like [b and ]b.
  { 'tpope/vim-unimpaired', event = 'VeryLazy' },

  -- Indent autodetection with editorconfig support.
  { 'tpope/vim-sleuth' },

  -- Allow plugins to enable repeating of commands.
  { 'tpope/vim-repeat' },

  -- Navigate seamlessly between Vim windows and Tmux panes.
  { 'christoomey/vim-tmux-navigator' },

  -- Jump to the last location when opening a file.
  { 'farmergreg/vim-lastplace' },

  -- Enable * searching with visually selected text.
  { 'nelstrom/vim-visual-star-search' },

  -- Automatically create parent dirs when saving.
  { 'jessarcher/vim-heritage' },

  -- Text objects for HTML attributes.
  { 'whatyouhide/vim-textobj-xmlattr', dependencies = 'kana/vim-textobj-user' },

  -- Automatically set the working directory to the project root.
  { import = 'user.plugins.vim-rooter' },

  -- Automatically add closing brackets, quotes, etc.
  { 'windwp/nvim-autopairs', config = true },

  -- Add smooth scrolling to avoid jarring jumps
  -- { 'karb94/neoscroll.nvim', config = true },

  -- All closing buffers without closing the split window.
  { import = 'user.plugins.bufdelete' },

  -- Split arrays and methods onto multiple lines, or join them back up.
  { import = 'user.plugins.treesj' },

  -- Automatically fix indentation when pasting code.
  { import = 'user.plugins.vim-pasta' },

  -- Fuzzy finder
  { import = 'user.plugins.telescope' },

  -- File tree sidebar
  { import = 'user.plugins.neo-tree' },

  -- A Status line.
  { import = 'user.plugins.lualine' },

  -- Display buffers as tabs.
  { import = 'user.plugins.bufferline' },

  -- Display indentation lines.
  { import = 'user.plugins.indent-blankline' },

  -- Add a dashboard.
  { import = 'user.plugins.dashboard-nvim' },

  -- Git integration.
  { import = 'user.plugins.gitsigns' },

  -- Git commands.
  { 'tpope/vim-fugitive', dependencies = 'tpope/vim-rhubarb' },

  --- Floating terminal.
  { import = 'user.plugins.floaterm' },

  -- Improved syntax highlighting
  { import = 'user.plugins.treesitter' },

  -- Debugging
  -- {
  --   "mfussenegger/nvim-dap",
  -- }

  -- Language Server Protocol.
  { import = 'user.plugins.lspconfig' },

  -- Formating & diagnostics.
  { import = 'user.plugins.none-ls' },

  -- Completion
  { import = 'user.plugins.cmp' },

  -- PHP Refactoring Tools
  { import = 'user.plugins.phpactor' },

  -- Project Configuration.
  { import = 'user.plugins.projectionist' },

  -- Testing helper
  { import = 'user.plugins.vim-test' },

  -- GitHub Copilot
  { import = 'user.plugins.copilot' },

  -- Colorize Hex Codes
  { import = 'user.plugins.colorizer' },

  -- Show file and LSP context in a bar at the top of the screen.
  { import = 'user.plugins.barbecue' },

  -- Virtual scrollbar
  { import = 'user.plugins.nvim-scrollbar' },

  -- Highlight occurrences of the word under the cursor.
  { import = 'user.plugins.illuminate' },

  -- trouble
  { import = 'user.plugins.trouble' },

  -- trouble
  { import = 'user.plugins.text-case' },

  -- undotree
  { import = 'user.plugins.undotree' },

  -- Nicer Code folding.
  { import = 'user.plugins.ufo' },

  -- Lazygit.
  { import = 'user.plugins.lazygit' },

  -- rendering md
  { import = 'user.plugins.render-markdown' },
}, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  install = {
    -- colorscheme = { "mellow", "habamax" },
    colorscheme = { 'tokyonight-storm', 'habamax' },
    -- colorscheme = { 'poimandres', 'habamax' },
    -- colorscheme = { 'nord', 'habamax' },
  },
})
