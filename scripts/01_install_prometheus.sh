#!/usr/bin/env bash
# Установка Prometheus из бинарников GitHub (по мотивам лекции OTUS)
set -euo pipefail
REPO_DIR=$(cd "$(dirname "$0")/.." && pwd)

VER=${VER:-$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep -Po '"tag_name": "v\K[^"]+')}
[ -n "$VER" ] || { echo "Не удалось определить версию. Запустите: VER=3.x.x $0"; exit 1; }
echo ">>> Prometheus v$VER"

cd /tmp
wget -q --show-progress -O prometheus.tar.gz \
  https://github.com/prometheus/prometheus/releases/download/v${VER}/prometheus-${VER}.linux-amd64.tar.gz

# Пользователь и каталоги
id prometheus &>/dev/null || useradd --no-create-home --shell /bin/false prometheus
mkdir -p /etc/prometheus /var/lib/prometheus

# Распаковка и бинарники
rm -rf prometheuspackage && mkdir prometheuspackage
tar -xzf prometheus.tar.gz -C prometheuspackage --strip-components=1
cp prometheuspackage/prometheus prometheuspackage/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# consoles / console_libraries есть только в 2.x
for d in consoles console_libraries; do
  [ -d prometheuspackage/$d ] && cp -r prometheuspackage/$d /etc/prometheus/
done

# Конфиг и сервис
cp "$REPO_DIR/configs/prometheus.yml" /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
promtool check config /etc/prometheus/prometheus.yml

cp "$REPO_DIR/configs/prometheus.service" /etc/systemd/system/prometheus.service
systemctl daemon-reload
systemctl enable --now prometheus
systemctl restart prometheus
sleep 2
systemctl --no-pager status prometheus
