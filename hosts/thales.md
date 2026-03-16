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
  - Docker: `https://download.docker.com/linux/debian trixie`
  - PostgreSQL: `https://apt.postgresql.org/pub/repos/apt trixie-pgdg`
  - TimescaleDB: `https://packagecloud.io/timescale/timescaledb/debian/ bookworm` (互換利用)
  - Tailscale: `https://pkgs.tailscale.com/stable/debian trixie`
  - **Grafana**: `https://apt.grafana.com stable main`

## 3. 稼働サービス一覧

| サービス名 | ポート (Host) | ローカルURL (HTTP) | 備考 / 認証情報 |
| :--- | :--- | :--- | :--- |
| **Apache2** | `80`, `443` | - | リバースプロキシ / `*.home`, `*.tk31z.net` (HTTPS), `thales.tail2346aa.ts.net` の入口 |
| **Grafana** | `3101` | `http://grafana.home` | 監視ダッシュボード / Admin: `admin` |
| **AdGuard Home** | `3000`, `53` | `http://adguard.home` | DNSリライト・広告ブロック (Snap) |
| **PostgreSQL 17** | `5432` | - | **Native (TimescaleDB 2.25.2)** / User: `postgres`, `takamiz` / Pass: `postgres` |
| **Stock Market API** | `3002` | `http://stock.home` | 株式データ同期・分析システム (Rust) |
| **Lorenzo** | `3001` | `http://lorenzo.home` | 蔵書管理システム (Docker) |
| **Immich** | `2283` | `http://immich.home` | 自宅フォトサーバー (Docker) |
| **WOL (Web UI)** | `8080` | `http://wol.home` | Wake-on-LAN (legion 起動用) / Docker |
| **Cockpit** | `9090` | `http://cockpit.home` | サーバー管理 Web UI |
| **Munin** | `4949` | `http://munin.home` | リソース監視 (Apache Direct Alias) |
| **WayVNC** | `5900` | - | リモートデスクトップ |
| **Samba** | `139`, `445` | - | ファイル共有 (smbd/nmbd) |
| **Loki** | `3100` | - | ログ集約エンジン (Binary) |
| **Prometheus** | `9091` | - | メトリクス集約サーバー (Port 9091 に変更済) |
| **Promtail** | `9080` | - | ログ収集エージェント (Binary) |

### 内部専用サービス (Docker Network)
- **immich_postgres**: PostgreSQL 16 (pgvecto-rs) / Port `5432` (内部のみ) / User: `postgres` / Pass: `postgres`
- **immich_redis**: Redis (内部)

## 4. ログ & メトリクス管理 (Grafana Stack)
各サービスのログとメトリクスは **Grafana** に集約されている。

| 収集対象 | ツール | ポート | 備考 |
| :--- | :--- | :--- | :--- |
| **ログ (Logs)** | Loki + Promtail | 3100, 9080 | システム, Apache2, Postgres, Stock |
| **システム (Node)** | Node Exporter | 9100 | CPU, RAM, Disk, Network |
| **DB (PostgreSQL)** | Postgres Exporter | 9187 | Queries, Locks, Connections |
| **集約サーバー** | Prometheus | 9091 | 15s スクリーピング間隔 |

## 5. 各サービス詳細設定

### Monitoring (Prometheus + Loki + Grafana)
- **Loki**: `~/services/loki/loki-linux-arm64` (Port 3100)
- **Promtail**: `~/services/loki/promtail-linux-arm64` (Port 9080)
- **Prometheus**: Port 9091 (Native) - Cockpit との競合回避のため
- **Grafana**: Port 3101 (Apache プロキシ `http://grafana.home`)
- **設定**: `systemd --user` (`loki.service`, `promtail.service`) および `systemctl` で管理。
- **Tailscale メトリクス収集**:
  - `tailscale metrics print` を `/var/lib/prometheus/node-exporter/tailscale.prom` に出力 (15秒ごと)
  - `systemd` タイマー: `tailscale-metrics.timer` / `tailscale-metrics.service`
  - スクリプト: `/usr/local/bin/tailscale-metrics-collect.sh`
  - node_exporter のテキストファイルコレクター経由で Prometheus に取り込み
  - `/etc/default/prometheus-node-exporter` に `--collector.textfile.directory` 設定済み
  - Grafana ダッシュボード: `http://grafana.home/d/1fe2dccd-cd7c-4f96-a512-30618fd68e63/tailscale`

### Stock Market System
- **構成**: Rust バイナリ (`bin/stock-market`, `bin/server`)
- **Database**: Native PostgreSQL 17 (`stock_market` DB)
- **実行**: `systemctl --user status stock-server.service`

### Immich (Docker)
- **構成**: `immich_server`, `immich_machine_learning`, `immich_postgres`, `immich_redis`
- **認証**: User: `postgres` / Pass: `postgres`

### SSL証明書 (Let's Encrypt)

- **ツール**: acme.sh (`~/.acme.sh/`) + Cloudflare DNS-01チャレンジ
- **ドメイン**: `*.tk31z.net` ワイルドカード証明書
- **証明書格納先**: `/etc/ssl/tk31z.net/`
  - `fullchain.pem`, `key.pem`, `cert.pem`
- **自動更新**: acme.sh の cron により自動更新（Apache も自動リロード）
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
| `https://adguard.tk31z.net` | `localhost:3000` |
| `https://grafana.tk31z.net` | `localhost:3101` |
| `https://immich.tk31z.net` | `localhost:2283` |
| `https://stock.tk31z.net` | `localhost:3002` |
| `https://lorenzo.tk31z.net` | `localhost:3001` |
| `https://cockpit.tk31z.net` | `localhost:9090` |
| `https://wol.tk31z.net` | `localhost:8080` |
| `https://munin.tk31z.net` | `localhost:4949` |
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
| `https://thales.tail2346aa.ts.net/adguard` | `localhost:3000` |
| `https://thales.tail2346aa.ts.net/grafana` | `localhost:3101` |
| `https://thales.tail2346aa.ts.net/immich` | `localhost:2283` |
| `https://thales.tail2346aa.ts.net/stock` | `localhost:3002` |
| `https://thales.tail2346aa.ts.net/lorenzo` | `localhost:3001` |
| `https://thales.tail2346aa.ts.net/cockpit` | `localhost:9090` |
| `https://thales.tail2346aa.ts.net/wol` | `localhost:8080` |
| `https://thales.tail2346aa.ts.net/munin` | `localhost:4949` |
| `https://thales.tail2346aa.ts.net/router` | `192.168.0.1` (ルーター管理画面) |

---

## 管理・メンテナンス
- **SSHログイン**: `ssh thales`
- **システム更新**: `sudo apt update && sudo apt upgrade`
- **PostgreSQL 接続確認**: `psql -h 192.168.0.200 -U postgres` (LAN内から)
- **Docker管理**: `docker ps`, `docker compose up -d`
- **監視管理**: `sudo systemctl status prometheus grafana-server`
