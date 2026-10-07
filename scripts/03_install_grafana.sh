#!/usr/bin/env bash
# Установка Grafana OSS из apt.grafana.com, порт 3001 (3000 занят Docker)
set -euo pipefail
GRAFANA_PORT=3001

apt-get install -y apt-transport-https wget gpg
mkdir -p /etc/apt/keyrings
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor --yes -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
  > /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y grafana

# Меняем порт
sed -i "s/^;\?http_port = .*/http_port = ${GRAFANA_PORT}/" /etc/grafana/grafana.ini
grep -n "^http_port" /etc/grafana/grafana.ini

systemctl daemon-reload
systemctl enable --now grafana-server
systemctl restart grafana-server
sleep 5
systemctl --no-pager status grafana-server
