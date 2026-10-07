#!/usr/bin/env bash
# Экспорт дашборда "Евгений Ермак / Evgenii Ermak" в JSON (dashboard as code)
set -euo pipefail
REPO_DIR=$(cd "$(dirname "$0")/.." && pwd)
GRAFANA=http://localhost:3001

read -rsp "Пароль пользователя admin в Grafana: " GPASS; echo
DUID=$(curl -s -u "admin:$GPASS" "$GRAFANA/api/search?query=Evgenii" | grep -Po '"uid":"\K[^"]+' | head -1)
[ -n "$DUID" ] || { echo "Дашборд не найден (проверьте пароль и название)"; exit 1; }

curl -s -u "admin:$GPASS" "$GRAFANA/api/dashboards/uid/$DUID" \
 | python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin)["dashboard"], ensure_ascii=False, indent=2))' \
 > "$REPO_DIR/dashboards/evgenii-ermak-dashboard.json"
echo ">>> Сохранено: dashboards/evgenii-ermak-dashboard.json"
