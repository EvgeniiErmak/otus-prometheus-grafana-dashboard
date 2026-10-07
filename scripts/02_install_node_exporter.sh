#!/usr/bin/env bash
# Установка Node Exporter из бинарников GitHub
set -euo pipefail
REPO_DIR=$(cd "$(dirname "$0")/.." && pwd)

VER=${VER:-$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep -Po '"tag_name": "v\K[^"]+')}
[ -n "$VER" ] || { echo "Не удалось определить версию. Запустите: VER=1.x.x $0"; exit 1; }
echo ">>> node_exporter v$VER"

cd /tmp
wget -q --show-progress -O node_exporter.tar.gz \
  https://github.com/prometheus/node_exporter/releases/download/v${VER}/node_exporter-${VER}.linux-amd64.tar.gz
rm -rf node_exporter_pkg && mkdir node_exporter_pkg
tar -xzf node_exporter.tar.gz -C node_exporter_pkg --strip-components=1

id nodeusr &>/dev/null || useradd -rs /bin/false nodeusr
systemctl stop node_exporter 2>/dev/null || true
cp node_exporter_pkg/node_exporter /usr/local/bin/

cp "$REPO_DIR/configs/node_exporter.service" /etc/systemd/system/node_exporter.service
systemctl daemon-reload
systemctl enable --now node_exporter
sleep 2
systemctl --no-pager status node_exporter
