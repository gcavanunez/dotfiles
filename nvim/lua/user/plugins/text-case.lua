return {
  "johmsalas/text-case.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  -- https://github.com/johmsalas/text-case.nvim
  config = function()
    require("textcase").setup({})
    require("telescope").load_extension("textcase")
  end,
  keys = {
    "ta", -- Default invocation prefix
    { "ta.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
  },
  cmd = {
    -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
    "Subs",
    "TextCaseOpenTelescope",
    "TextCaseOpenTelescopeQuickChange",
    "TextCaseOpenTelescopeLSPChange",
    "TextCaseStartReplacingCommand",
  },
  -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
  -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
  -- available after the first executing of it or after a keymap of text-case.nvim has been used.
  lazy = false,
}
