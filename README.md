# OTUS · Prometheus + Grafana: дашборд CPU / RAM / Disk / Network

**Автор:** Евгений Ермак (Evgenii Ermak)

## Задание
Настроить дашборд с 4 графиками — **память, процессор, диск, сеть** — на связке **Prometheus + Grafana**.
Название дашборда: **«Евгений Ермак / Evgenii Ermak»**.

## Стенд
| Компонент | Источник | Порт |
|-----------|----------|------|
| Ubuntu 26.04.1 LTS, хост `otus-slave` (192.168.88.238) | — | — |
| Prometheus | бинарники GitHub (последний релиз) | 9090 |
| node_exporter | бинарники GitHub (последний релиз) | 9100 |
| Grafana OSS | apt.grafana.com | 3001 (3000 занят Docker) |

## Структура репозитория
- 📁 [configs/](configs/) — [prometheus.yml](configs/prometheus.yml), [prometheus.service](configs/prometheus.service), [node_exporter.service](configs/node_exporter.service)
- 📁 [scripts/](scripts/) — скрипты установки, экспорта дашборда и публикации в GitHub
- 📁 [dashboards/](dashboards/) — JSON дашборда (dashboard as code)
- 📁 [screenshots/](screenshots/) — скриншоты выполнения

## Панели дашборда
| Панель | PromQL | Единицы |
|--------|--------|---------|
| Процессор | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)` | Percent (0-100) |
| Память | `100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)` | Percent (0-100) |
| Диск (чтение / запись) | `rate(node_disk_read_bytes_total{device="nvme0n1"}[1m])`<br>`rate(node_disk_written_bytes_total{device="nvme0n1"}[1m])` | bytes/sec (IEC) |
| Сеть (вход / выход) | `rate(node_network_receive_bytes_total{device="enp2s0"}[1m]) * 8`<br>`rate(node_network_transmit_bytes_total{device="enp2s0"}[1m]) * 8` | bits/sec (SI) |

## Как повторить
```bash
bash scripts/01_install_prometheus.sh
bash scripts/02_install_node_exporter.sh
bash scripts/03_install_grafana.sh
# Grafana: http://<IP>:3001 (admin/admin) → Data source Prometheus http://localhost:9090 → дашборд из 4 панелей
bash scripts/04_export_dashboard.sh
bash scripts/git_push.sh
```
