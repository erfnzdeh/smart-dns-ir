#!/bin/bash
# Bootstrap Ubuntu apt when public DNS (UDP/TCP 53) or international mirrors fail:
# - Pin mirror.arvancloud.ir to CDN IPs via /etc/hosts (HTTP still works).
# - Point Ubuntu deb822 sources to Arvan (noble + noble-security on same mirror).
#
# Run as root before setup_ubuntu_dns.sh on restricted networks (e.g. no intl egress).

set -euo pipefail

if [ "${EUID:-}" -ne 0 ]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

# IPs for mirror.arvancloud.ir (verify with: dig +short mirror.arvancloud.ir A)
ARVAN_MIRROR_IPS=(185.143.234.235 185.143.233.235)
HOSTS_LINE="# matrix-install: Arvan Ubuntu mirror (for apt when DNS to resolvers is blocked)"
MARK_BEGIN="# BEGIN matrix-install-arvan-hosts"
MARK_END="# END matrix-install-arvan-hosts"

echo "==> Ensuring /etc/hosts entries for mirror.arvancloud.ir"
if ! grep -q "mirror.arvancloud.ir" /etc/hosts 2>/dev/null; then
  {
    echo ""
    echo "$MARK_BEGIN"
    echo "$HOSTS_LINE"
    for ip in "${ARVAN_MIRROR_IPS[@]}"; do
      echo "$ip mirror.arvancloud.ir"
    done
    echo "$MARK_END"
  } >> /etc/hosts
else
  echo "    (mirror.arvancloud.ir already present — skipping hosts append)"
fi

UBUNTU_SOURCES=/etc/apt/sources.list.d/ubuntu.sources
if [ -f "$UBUNTU_SOURCES" ]; then
  echo "==> Pointing apt to Arvan mirror in $UBUNTU_SOURCES"
  cp -a "$UBUNTU_SOURCES" "${UBUNTU_SOURCES}.bak.$(date +%Y%m%d%H%M%S)"
  sed -i \
    -e 's|URIs: http://archive.ubuntu.com/ubuntu|URIs: http://mirror.arvancloud.ir/ubuntu|g' \
    -e 's|URIs: http://security.ubuntu.com/ubuntu|URIs: http://mirror.arvancloud.ir/ubuntu|g' \
    -e 's|https://archive.ubuntu.com/ubuntu|http://mirror.arvancloud.ir/ubuntu|g' \
    -e 's|https://security.ubuntu.com/ubuntu|http://mirror.arvancloud.ir/ubuntu|g' \
    "$UBUNTU_SOURCES" || true
fi

echo "==> apt-get update"
apt-get update -qq

echo "✅ Bootstrap done. Next: bash setup_ubuntu_dns.sh"
