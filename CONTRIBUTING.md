# Contributing

Bugs, extra resolvers, and patches are welcome. This installer runs as root
and rewrites a live server's DNS, so a change that looks small in git can
take a box offline.

## Before you write code

Open an [issue](https://github.com/erfnzdeh/smart-dns-ir/issues) if the
change is more than a typo, a new resolver, or an obvious bug.

Things to keep:

- **The `MANUAL-BEGIN` / `MANUAL-END` block in `/etc/dnsmasq.conf` must
  survive updates.** `smart-dns-ir-update` rewrites upstreams; it must not
  eat operator overrides.
- **Containers must keep using the dnsmasq bridge IP.** Never teach compose
  files or `daemon.json` to point at a public resolver. That skips the
  cache, `bogus-nxdomain`, and the health check.
- **Uninstall must not remove dnsmasq or rewrite `resolv.conf` back.** It
  removes our scripts and timers. The rest is the operator's.

There is no test suite. `bash -n` on every script is the check CI runs.
If you change benchmark scoring or the doctor rewrite, say how you ran it
on a real box (or why you could not).

## Setup

```bash
git clone https://github.com/erfnzdeh/smart-dns-ir.git
cd smart-dns-ir
bash -n install.sh uninstall.sh benchmark.sh dns-updater.sh \
  dns-health-check.sh dns-doctor.sh bootstrap-apt.sh
./benchmark.sh
```

`benchmark.sh` is safe without root. `install.sh` is not; use a throwaway
VPS or a VM.

## Pull requests

- One change per PR.
- Match the surrounding shell. Prefer `set -euo pipefail` and no em dashes
  in comments or docs.
- A new resolver needs a provider name and at least one IP. A new test
  domain needs a reason (international vs domestic, or a censorship case).
- Do not commit a live `/etc/dnsmasq.conf` or a `daemon.json` from a
  machine you actually run.

## Surfaces

| Path | What it is |
|---|---|
| `install.sh` | Root installer: packages, dnsmasq, timers, Docker, UFW. |
| `benchmark.sh` | Parallel latency + censorship probe. Also used standalone. |
| `dns-updater.sh` | Re-benchmark and rewrite upstreams. Installed as `smart-dns-ir-update`. |
| `dns-health-check.sh` | Host + container probe, every five minutes. |
| `dns-doctor.sh` | Finds compose `dns:` lines that bypass dnsmasq. |
| `bootstrap-apt.sh` | Arvan apt mirror when public mirrors are unreachable. |
| `uninstall.sh` | Removes our files. Leaves dnsmasq installed. |

Contributions are under the same MIT license as the rest of the repo.
