#!/usr/bin/env bash
# Создание репозитория на GitHub через API и push с помощью Personal access token (classic)
set -euo pipefail
GH_USER="EvgeniiErmak"
GH_EMAIL="djermak3000@mail.ru"
REPO="otus-prometheus-grafana-dashboard"
cd "$(dirname "$0")/.."

read -rsp "GitHub Personal access token (classic): " GH_TOKEN; echo

# 1. Создаём репозиторий (201 - создан, 422 - уже существует)
CODE=$(curl -s -o /tmp/gh_create.json -w "%{http_code}" \
  -H "Authorization: token $GH_TOKEN" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO\",\"description\":\"OTUS: Prometheus + Grafana - dashboard CPU/RAM/Disk/Network\",\"private\":false}")
case "$CODE" in
  201) echo ">>> Репозиторий создан: https://github.com/$GH_USER/$REPO" ;;
  422) echo ">>> Репозиторий уже существует, продолжаем" ;;
  *)   echo ">>> Ошибка API GitHub ($CODE):"; cat /tmp/gh_create.json; exit 1 ;;
esac

# 2. Локальный git
[ -d .git ] || git init -q
git config user.name  "$GH_USER"
git config user.email "$GH_EMAIL"
git add -A
git commit -q -m "Prometheus + Grafana: dashboard CPU/RAM/Disk/Network" || echo ">>> Нет новых изменений для коммита"
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$GH_USER/$REPO.git"

# 3. Push (токен передаётся заголовком и нигде не сохраняется)
AUTH=$(printf '%s:%s' "$GH_USER" "$GH_TOKEN" | base64 -w0)
git -c http.extraHeader="Authorization: Basic $AUTH" pull --rebase origin main 2>/dev/null || true
git -c http.extraHeader="Authorization: Basic $AUTH" push -u origin main

echo ">>> Готово: https://github.com/$GH_USER/$REPO"
