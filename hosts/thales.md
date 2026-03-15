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
- **DNS (AdGuard Home)**: Snap経由。`*.home` -> `100.100.163.37`
- **リポジトリ (APT Sources)**: 再構築時に以下の追加が必要
  - Docker: `https://download.docker.com/linux/debian trixie`
  - PostgreSQL: `https://apt.postgresql.org/pub/repos/apt trixie-pgdg`
  - TimescaleDB: `https://packagecloud.io/timescale/timescaledb/debian/ bookworm` (互換利用)
  - Tailscale: `https://pkgs.tailscale.com/stable/debian trixie`
  - **Grafana**: `https://apt.grafana.com stable main`

## 3. 稼働サービス一覧

| サービス名 | ポート (Host) | ローカルURL (HTTP) | 備考 / 認証情報 |
| :--- | :--- | :--- | :--- |
| **Apache2** | `80` | - | リバースプロキシ / `*.home` および `thales.tail2346aa.ts.net` の入口 |
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

### Stock Market System
- **構成**: Rust バイナリ (`bin/stock-market`, `bin/server`)
- **Database**: Native PostgreSQL 17 (`stock_market` DB)
- **実行**: `systemctl --user status stock-server.service`

### Immich (Docker)
- **構成**: `immich_server`, `immich_machine_learning`, `immich_postgres`, `immich_redis`
- **認証**: User: `postgres` / Pass: `postgres`

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

---

## 管理・メンテナンス
- **SSHログイン**: `ssh thales`
- **システム更新**: `sudo apt update && sudo apt upgrade`
- **PostgreSQL 接続確認**: `psql -h 192.168.0.200 -U postgres` (LAN内から)
- **Docker管理**: `docker ps`, `docker compose up -d`
- **監視管理**: `sudo systemctl status prometheus grafana-server`
