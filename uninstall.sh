#!/bin/bash
# iran-dns: Uninstaller
# Removes iran-dns scripts, systemd units, and cron jobs.
# Does NOT remove dnsmasq itself (you may be using it for other things).
# Usage: sudo bash uninstall.sh

set -euo pipefail

if [[ "${EUID:-}" -ne 0 ]]; then
    echo "Run as root: sudo bash uninstall.sh"
    exit 1
fi

echo "Removing iran-dns..."

# Stop and disable timer
systemctl stop iran-dns-health-check.timer 2>/dev/null || true
systemctl disable iran-dns-health-check.timer 2>/dev/null || true

# Remove systemd units
rm -f /etc/systemd/system/iran-dns-health-check.service
rm -f /etc/systemd/system/iran-dns-health-check.timer
rm -f /etc/systemd/system/dnsmasq.service.d/restart.conf
rmdir /etc/systemd/system/dnsmasq.service.d 2>/dev/null || true
systemctl daemon-reload

# Remove scripts
rm -f /usr/local/bin/iran-dns-update
rm -f /usr/local/bin/iran-dns-health-check
rm -f /usr/local/bin/iran-dns-benchmark

# Remove cron job
(crontab -l 2>/dev/null | grep -v "iran-dns-update") | crontab - 2>/dev/null || true

# Remove state directory
rm -rf /var/lib/iran-dns

echo ""
echo "Removed:"
echo "  - systemd timer and service"
echo "  - /usr/local/bin/iran-dns-*"
echo "  - cron job"
echo "  - /var/lib/iran-dns/"
echo ""
echo "NOT removed (manual cleanup if desired):"
echo "  - dnsmasq package and /etc/dnsmasq.conf"
echo "  - /etc/sysctl.d/99-disable-ipv6.conf"
echo "  - /etc/systemd/resolved.conf.d/no-stub.conf"
echo "  - /etc/docker/daemon.json"
echo "  - /var/log/iran-dns-*.log"
