# Pi

`prompts/` and `extensions/` contain stable, declarative Pi customization.
`./install` links prompts and each owned runtime extension into
`${PI_CODING_AGENT_DIR:-~/.pi/agent}`.

- `/discuss` expands the planning-interview prompt.
- `/answer` extracts questions from the last assistant response, collects
  answers interactively, and submits one response.
- `/goal <objective>` starts a persistent goal with at most ten automatic turns.
  `/goal pause`, `/goal resume`, and `/goal clear` control it; resume explicitly
  authorizes another ten-turn segment. Restored goals pause until explicitly
  resumed.

Pi keeps settings, credentials, trust decisions, installed packages, model
metadata, and sessions in its agent directory; those files are intentionally
machine-local. Pi mutates global settings during normal use, so
`settings.json` must not be linked into this repository. Shared agent skills
remain canonical in `~/.agents/skills` and are discovered by Pi directly.

## Herdr integration

`./install` runs `herdr integration install pi`. Herdr writes and owns
`${PI_CODING_AGENT_DIR:-~/.pi/agent}/extensions/herdr-agent-state.ts`; it is
intentionally not linked into this repository. Reinstalling after a Herdr
upgrade refreshes the extension to the protocol version bundled with that
Herdr release.

Inside a Herdr pane, the extension reports Pi's session identity and
`working`, `blocked`, or `idle` lifecycle state. Outside Herdr it is a no-op.
Herdr can use the session identity to restore Pi after a server restart.

Check it with `herdr integration status` or `./doctor`. Do not edit the generated
extension; add any extensions we own beside it and track their source here.

The installer links owned extensions individually so Herdr can manage its file
in the same destination directory. It refuses to replace an existing file or a
symlink owned by another setup.

## Package policy

Keep the machine-local global package list small. Packages and extensions
execute with full user access, so review their source and dependency tree
before adding them. Inspect the current list with `pi list`.

An isolated install of `mitsuhiko/agent-stuff` at commit `13bc8f8` pulled a
second, older Pi peer tree and reported eight production dependency findings
(one critical and five high). Do not load the package wholesale until that
dependency behavior has been resolved upstream or re-reviewed.

The local `goal.ts` and `answer.ts` reimplement selected ideas from
`mitsuhiko/agent-stuff` for the current Pi API. They are smaller, locally tested,
and avoid installing the full package. Other extensions to evaluate individually
are:

- `btw.ts`, `files.ts`, `prompt-editor.ts`, and `todos.ts`
- `notify.ts`, `review.ts`, and `session-breakdown.ts`
- `control.ts` and `subagent.ts` for supervised multi-agent work

Do not adopt `uv.ts`, `unified-edit.ts`, `trust-github-repos.ts`, or
terminal-specific extensions without choosing their policy explicitly.

## Maintenance

Run `pi config` to review enabled resources. Use `pi update --extensions` to
update unpinned packages.

After changing packages, prompts, or extensions, restart Pi or run `/reload` in
an active session.

Run the owned extension tests with `bun run --cwd pi test`.
