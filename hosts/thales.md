# Machine Record: thales

## 1. システム環境 (Reconstruction Guide)
- **ホスト名**: `thales` (IP: `192.168.0.200`)
- **OS**: Debian GNU/Linux 13 (trixie) - Raspberry Pi OS 64-bit (Testing)
- **アーキテクチャ**: `arm64` (Raspberry Pi 4/5)
- **カーネル**: `6.12.x-rpt-rpi-v8`
- **ストレージ**:
  - `/dev/sdb2` (235G): ルートパーティション (`ext4`)
  - `/dev/sda1` (3.7T): 外部USB-HDD (`xfs`) - `/mnt/usb-hdd` にマウント
  - **ZRAM**: `zram0` (swap用) 有効化済み

## 2. ネットワーク & パッケージリポジトリ
- **SSH**: 鍵認証 (`~/.ssh/id_ed25519`), `NOPASSWD` 設定済み
- **DNS (AdGuard Home)**: Snap経由。`*.home` / `*.tk31z.net` → `192.168.0.200`
- **リポジトリ (APT Sources)**: 再構築時に以下の追加が必要
  - PostgreSQL: `https://apt.postgresql.org/pub/repos/apt trixie-pgdg`
  - TimescaleDB: `https://packagecloud.io/timescale/timescaledb/debian/ bookworm` (互換利用)
  - Tailscale: `https://pkgs.tailscale.com/stable/debian trixie`
  - ~~**Grafana**: `https://apt.grafana.com stable main`~~ (削除済み)

## 3. 稼働サービス一覧

| サービス名 | ポート (Host) | ローカルURL (HTTP) | 備考 / 認証情報 |
| :--- | :--- | :--- | :--- |
| **Apache2** | `80`, `443` | - | リバースプロキシ / `*.home`, `*.tk31z.net` (HTTPS), `thales.tail2346aa.ts.net` の入口 |
| **AdGuard Home** | `3004`, `53` | `http://adguard.home` | DNSリライト・広告ブロック (Snap) / ※旧port 3000 → 3004 変更済み (stock-db 衝突回避, 2026-04-05) |
| **PostgreSQL 17** | `5432` | - | **Native (TimescaleDB 2.26.0)** / User: `postgres`, `takamiz` / Pass: `postgres` |
| **Stock Trader API** | `3001` | `http://trader.home` | 株式トレード・ダッシュボード (Rust) / `stock-trader-server.service` (systemd --user) |
| **Jaeger** | `16686` | `http://jaeger.home` | 分散トレーシング UI (v2.17.0) / `jaeger.service` (systemd --user) |
| **pgAdmin 4** | `5050` | `http://pgadmin.home` | PostgreSQL 管理 Web UI / `pgadmin4.service` (systemd --user) / pip install |
| **Cockpit** | `9090` | `http://cockpit.home` | サーバー管理 Web UI |
| Munin | `80` | `http://munin.home` | リソース監視 (Apache Direct Alias) |
| **WayVNC** | `5900` | - | リモートデスクトップ / `wayvnc.service` + `rpi-connect-wayvnc.service` |
| **Samba** | `139`, `445` | - | ファイル共有 (smbd/nmbd) |
| **Node Exporter** | `9100` | - | システムメトリクス収集 (Prometheus exporter) |
| **Postgres Exporter** | `9187` | - | PostgreSQL メトリクス収集 (Prometheus exporter) |
| **Raspberry Pi Connect** | - | - | リモートアクセス (rpi-connect.service / systemd --user) |

### 停止中のサービス

| サービス名 | 最終ポート | 状態 | 備考 |
| :--- | :--- | :--- | :--- |
| **Prometheus** | `9091` | `disabled` | prometheus.service / APT |
| **Loki** | `3100` | `disabled` | loki.service / systemd --user (Binary) |
| **Promtail** | `9080` | `disabled` | promtail.service / systemd --user (Binary) |

## 4. メトリクス管理 (Exporters)
Prometheus/Loki スタックは現在停止中。Exporter のみ稼働中。

| 収集対象 | ツール | ポート | 状態 | 備考 |
| :--- | :--- | :--- | :--- | :--- |
| **システム (Node)** | Node Exporter | 9100 | 稼働中 | CPU, RAM, Disk, Network |
| **DB (PostgreSQL)** | Postgres Exporter | 9187 | 稼働中 | Queries, Locks, Connections |
| **ログ (Logs)** | Loki + Promtail | 3100, 9080 | **停止中** | システム, Apache2, Postgres, Stock |
| **集約サーバー** | Prometheus | 9091 | **停止中** | 15s スクリーピング間隔 |

## 5. 各サービス詳細設定

### Monitoring (Exporters のみ稼働中)
- **Node Exporter**: Port 9100 (`prometheus-node-exporter.service` / APT パッケージ)
- **Postgres Exporter**: Port 9187 (`prometheus-postgres-exporter.service` / APT パッケージ)
- **Loki**: `~/services/loki/loki-linux-arm64` (Port 3100) - **停止中** (loki.service disabled)
- **Promtail**: `~/services/loki/promtail-linux-arm64` (Port 9080) - **停止中** (promtail.service disabled)
- **Prometheus**: Port 9091 - **停止中** (prometheus.service disabled)
- **Tailscale メトリクス収集** (設定済み・Prometheus 停止中):
  - `tailscale metrics print` を `/var/lib/prometheus/node-exporter/tailscale.prom` に出力 (15秒ごと)
  - `systemd` タイマー: `tailscale-metrics.timer` / `tailscale-metrics.service`
  - スクリプト: `/usr/local/bin/tailscale-metrics-collect.sh`
  - node_exporter のテキストファイルコレクター経由で Prometheus に取り込む設定
  - `/etc/default/prometheus-node-exporter` に `--collector.textfile.directory` 設定済み

### Jaeger (分散トレーシング)

- **バージョン**: v2.17.0
- **バイナリ**: `~/services/jaeger/jaeger`
- **設定ファイル**: `~/services/jaeger/config.yaml`
- **ストレージ**: インメモリ (max_traces: 100,000)
- **実行**: `systemctl --user status jaeger.service`
- **ポート**:
  - UI: `16686`
  - OTLP gRPC: `4317`
  - OTLP HTTP: `4318`
  - Jaeger Thrift HTTP: `14268`
  - Jaeger Protobuf gRPC: `14250`

### WOL (Wake-on-LAN)
- **構成**: Python Flask + Gunicorn (`~/services/wol/`)
- **実行**: `systemctl status wol.service` (システムサービス)
- **設定**: `/etc/systemd/system/wol.service` (`User=takamiz`, `network-online.target` 依存)
- **対象**: legion (`98:ee:cb:d9:58:40` / `192.168.0.127`)
- **注意**: 旧ユーザーサービス (`~/.config/systemd/user/wol.service`) は 2026-03-28 に削除済み

### SSL証明書 (Let's Encrypt)

- **ツール**: acme.sh (`~/.acme.sh/`) + Cloudflare DNS-01チャレンジ
- **ドメイン**: `*.tk31z.net` ワイルドカード証明書
- **証明書格納先**: `/etc/ssl/tk31z.net/`
  - `fullchain.pem`, `key.pem`, `cert.pem`
- **自動更新**: systemd タイマー (`acme-renew.timer` / systemd --user) により毎日更新（Apache も自動リロード）
  - `~/.config/systemd/user/acme-renew.service` + `acme-renew.timer`
  - `Persistent=true` 設定済み（停止中の発火分は次回起動時に実行）
- **Cloudflare APIトークン**: `~/.acme.sh/account.conf` に保存済み

```bash
# 証明書の状態確認
~/.acme.sh/acme.sh --list

# 手動更新
CF_Token=$(cat ~/.config/cloudflare/api_token) ~/.acme.sh/acme.sh --renew -d tk31z.net --force
```

### Apache HTTPS (tk31z.net)

- **設定ファイル**: `/etc/apache2/sites-enabled/tk31z.conf`
- **Listen**: `192.168.0.200:443`（Tailscale Serve が `100.100.163.37:443` を使用するため LAN IP のみ）
- **証明書**: `/etc/ssl/tk31z.net/fullchain.pem`

| URL | 転送先 |
| :--- | :--- |
| `https://adguard.tk31z.net` | `localhost:3004` |
| `https://trader.tk31z.net` | `localhost:3001` |
| `https://cockpit.tk31z.net` | `localhost:9090` |
| `https://wol.tk31z.net` | `localhost:8080` |
| `https://munin.tk31z.net` | 静的ファイル直接配信 (`/var/cache/munin/www`) |
| `https://jaeger.tk31z.net` | `localhost:16686` |
| `https://pgadmin.tk31z.net` | `localhost:5050` |
| `https://router.tk31z.net` | `192.168.0.1` |

---

## 6. Tailscale Serve 設定

`tailscale serve` でポート80（Apache）をTailscaleネットワークに公開している。

```bash
# 設定確認
tailscale serve status

# 設定（初回 or 再構築時）
sudo tailscale set --operator=takamiz
tailscale serve --bg http://localhost:80
```

Apache VirtualHost (`/etc/apache2/sites-enabled/tailscale.conf`) でパスルーティング:

| パス | 転送先 |
| :--- | :--- |
| `https://thales.tail2346aa.ts.net/adguard` | `localhost:3004` |
| `https://thales.tail2346aa.ts.net/trader` | `localhost:3001` |
| `https://thales.tail2346aa.ts.net/cockpit` | `localhost:9090` |
| `https://thales.tail2346aa.ts.net/wol` | `localhost:8080` |
| `https://thales.tail2346aa.ts.net/munin` | `localhost:80` |
| `https://thales.tail2346aa.ts.net/jaeger` | `localhost:16686` |
| `https://thales.tail2346aa.ts.net/pgadmin` | `localhost:5050` |
| `https://thales.tail2346aa.ts.net/router` | `192.168.0.1` (ルーター管理画面) |

---

## 管理・メンテナンス
- **SSHログイン**: `ssh thales`
- **システム更新**: `sudo apt update && sudo apt upgrade`
- **ヘルスチェック**: `check-services` — 全サービスの死活を一覧表示 (`/usr/local/bin/check-services`)
- **PostgreSQL 接続確認**: `psql -h 192.168.0.200 -U postgres` (LAN内から)
- **Exporter 確認**: `sudo systemctl status prometheus-node-exporter prometheus-postgres-exporter`
- **監視管理** (停止中): `sudo systemctl status prometheus`
