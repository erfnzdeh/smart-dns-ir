# Security

`install.sh` runs as root. It replaces the host resolver, opens UFW for
Docker bridges, writes systemd units, and adds a cron job. A bug here is
not a docs problem.

## Reporting

Do not open a public issue for:

- a way for an unprivileged user to change `/etc/dnsmasq.conf` or the
  systemd units this installs
- command injection through a domain, IP, or compose path the scripts
  interpolate
- a way the health check or updater would run attacker-controlled shell
- a leaked host config you pasted from a real server

Use a
[private vulnerability advisory](https://github.com/erfnzdeh/smart-dns-ir/security/advisories/new).
Say what you can reach and on which script. Do not include a live
`dnsmasq.conf` from a production box.

## In scope

- Privilege escalation from the installed scripts or timers
- Unexpected writes outside the documented paths
- The doctor rewriting a compose file it should not touch
- Firewall rules wider than the Docker bridges we detected

## Out of scope

- Replacing `systemd-resolved` or `unbound`. That is the installer.
- Pointing the host at Iranian resolvers. That is the point.
- A domain still resolving to `10.10.34.x` until you add a
  `bogus-nxdomain` or `server=/domain/ip` override. Censorship changes;
  the MANUAL block is how you catch up.
- Docker containers that bypass dnsmasq because their compose file has
  an external `dns:` entry. The doctor exists for that; it is a
  misconfiguration, not a vuln in this repo.

## Operator notes

Review `/etc/dnsmasq.conf` after install. Keep overrides inside
`MANUAL-BEGIN` / `MANUAL-END`. If you ever ran the installer from a
fork you do not trust, re-read the units in `/etc/systemd/system` and
the cron line before leaving it on a box that matters.
