# First-party Rex upgrade/restart support

Checked through **Server & CLI preview.18 on 2026-11-12**, using Superlogical MCP.

- Rex documents `server stop`, `server start`, and `server status`, but no
  all-in-one Linux `server restart`, `update`, or `upgrade` command.[1]
- Installing a newer package leaves a manually started personal server running
  the old binary. Rex's documented activation step is stop, then start again,
  preserving any required start flags.[2]
- A stop ends the programs running in the server's sessions. Restored layouts
  are not running-process continuity. `server stop --if-idle` is a first-party
  option that refuses to stop a busy server, on supported builds.[3]
- `rex server install` is first-party service/startup setup, not a local package
  updater. On Linux it enables packaged systemd user units; server options go
  in a machine-local service drop-in. Adopting it is optional, not necessary
  for an on-demand updater.[4]
- Rex for Mac has `client.server.restart`, but it explicitly restarts the
  app's **local** server. It is not a Linux-server update/restart command.[5]

For the existing manually started setup, upgrade packages separately, then use
Rex's native stop/start commands from a small **local** Bash script.
Run it outside the server being restarted. Keep host-specific flags in a
private configuration file outside the public checkout, not in the script.
The repository's `scripts/upgrade-rex` only performs that restart/status step;
SSH and package updates are left to the caller.

These findings describe documented shipped behavior, not every build's hidden
commands. Community proposals alone are not evidence of a shipped updater.

[1]: https://www.superlogical.com/rex/docs/reference/cli#server
[2]: https://www.superlogical.com/rex/docs/linux/upgrading#what-restarts
[3]: https://www.superlogical.com/rex/docs/reference/cli#rex-server-stop
[4]: https://www.superlogical.com/rex/docs/reference/cli#rex-server-install-flags-sshuserhostport----server-flag
[5]: https://www.superlogical.com/rex/docs/reference/mac-actions#action-client-server-restart
