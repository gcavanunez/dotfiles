return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    -- For logging that is to a file if you wish to trace through requests
    -- for reporting bugs, i would not rely on this, but instead the provided
    -- logging mechanisms within 99.  This is for more debugging purposes
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)

    _99.setup({
      -- provider = _99.Providers.ClaudeCodeProvider,  -- default: OpenCodeProvider
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },
      -- When setting this to something that is not inside the CWD tools
      -- such as claude code or opencode will have permission issues
      -- and generation will fail refer to tool documentation to resolve
      -- https://opencode.ai/docs/permissions/#external-directories
      -- https://code.claude.com/docs/en/permissions#read-and-edit
      tmp_dir = "./tmp",

      --- Completions: #rules and @files in the prompt buffer
      completion = {
        -- I am going to disable these until i understand the
        -- problem better.  Inside of cursor rules there is also
        -- application rules, which means i need to apply these
        -- differently
        -- cursor_rules = "<custom path to cursor rules>"

        --- A list of folders where you have your own SKILL.md
        --- Expected format:
        --- /path/to/dir/<skill_name>/SKILL.md
        ---
        --- Example:
        --- Input Path:
        --- "scratch/custom_rules/"
        ---
        --- Output Rules:
        --- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
        --- ... the other rules in that dir ...
        ---
        custom_rules = {
          "scratch/custom_rules/",
        },

        --- Configure @file completion (all fields optional, sensible defaults)
        files = {
          -- enabled = true,
          -- max_file_size = 102400,     -- bytes, skip files larger than this
          -- max_files = 5000,            -- cap on total discovered files
          -- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
        },
        --- File Discovery:
        --- - In git repos: Uses `git ls-files` which automatically respects .gitignore
        --- - Non-git repos: Falls back to filesystem scanning with manual excludes
        --- - Both methods apply the configured `exclude` list on top of gitignore

        --- What autocomplete engine to use. Defaults to native (built-in) if not specified.
        source = "blink", -- "native" (default), "cmp", or "blink"
      },

      --- WARNING: if you change cwd then this is likely broken
      --- ill likely fix this in a later change
      ---
      --- md_files is a list of files to look for and auto add based on the location
      --- of the originating request.  That means if you are at /foo/bar/baz.lua
      --- the system will automagically look for:
      --- /foo/bar/AGENT.md
      --- /foo/AGENT.md
      --- assuming that /foo is project root (based on cwd)
      md_files = {
        "AGENT.md",
      },
      provider = _99.Providers.OpenCodeProvider,
      -- model is optional, overrides the provider's default
      model = "anthropic/claude-sonnet-4-6",
    })

    -- take extra note that i have visual selection only in v mode
    -- technically whatever your last visual selection is, will be used
    -- so i have this set to visual mode so i dont screw up and use an
    -- old visual selection
    --
    -- likely ill add a mode check and assert on required visual mode
    -- so just prepare for it now
    vim.keymap.set("n", "<leader>9s", function()
      _99.search()
    end)
    vim.keymap.set("v", "<leader>9vv", function()
      _99.visual()
    end)
    vim.keymap.set("v", "<leader>9vp", function()
      _99.visual_prompt()
    end)
    vim.keymap.set("n", "<leader>9x", function()
      _99.stop_all_requests()
    end)
    vim.keymap.set("n", "<leader>9i", function()
      _99.info()
    end)
    vim.keymap.set("n", "<leader>9l", function()
      _99.view_logs()
    end)
    vim.keymap.set("n", "<leader>9n", function()
      _99.next_request_logs()
    end)
    vim.keymap.set("n", "<leader>9p", function()
      _99.prev_request_logs()
    end)

    --------------------------------------------------------------------------
    -- Code Review prototype
    --
    -- <leader>wd  - set the work description (what you're building)
    -- <leader>ww  - review all unpushed/staged/unstaged changes against it
    -- <leader>wc  - clear the work description
    --------------------------------------------------------------------------
    local work_description = ""

    vim.keymap.set("n", "<leader>wd", function()
      vim.ui.input({ prompt = "Work description: " }, function(input)
        if input and #input > 0 then
          work_description = input
          print("[99 review] work set: " .. input)
        end
      end)
    end, { desc = "99: set work description for code review" })

    vim.keymap.set("n", "<leader>wc", function()
      work_description = ""
      print("[99 review] work description cleared")
    end, { desc = "99: clear work description" })

    vim.keymap.set("n", "<leader>ww", function()
      if work_description == "" then
        print("[99 review] set a work description first with <leader>wd")
        return
      end

      _99.search({
        additional_prompt = string.format([[
<YourTask>
* run `git diff` to get all unstaged changes
* run `git diff --staged` to get all staged changes
* run `git log --oneline @{upstream}..HEAD 2>/dev/null` to find unpushed commits
* if unpushed commits exist, run `git diff @{upstream}..HEAD` for the full unpushed diff
* if any of those commands fail (e.g. no upstream), skip that source and move on
* combine all collected diffs into a single changeset
* compare the full changeset against the work description below
* sequentially walk through each changed file and diff hunk looking for:
  - bugs, logic errors, off-by-one mistakes
  - behaviors that deviate from the work description
  - missing error handling, unchecked return values, missing awaits
  - unfinished TODOs or empty/stub implementations
  - type mismatches or incorrect API usage
  - race conditions or resource leaks
* for each issue found, report the exact file and line location with a clear
  description of the problem
</YourTask>
<Description>%s</Description>
]], work_description),
      })
    end, { desc = "99: review changes against work description" })
  end,
}
