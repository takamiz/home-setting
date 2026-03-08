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
- **DNS (AdGuard Home)**: Snap経由。`*.thales.home` -> `192.168.0.200`
- **リポジトリ (APT Sources)**: 再構築時に以下の追加が必要
  - Docker: `https://download.docker.com/linux/debian trixie`
  - PostgreSQL: `https://apt.postgresql.org/pub/repos/apt trixie-pgdg`
  - TimescaleDB: `https://packagecloud.io/timescale/timescaledb/debian/ bookworm` (互換利用)
  - Tailscale: `https://pkgs.tailscale.com/stable/debian trixie`

## 3. 稼働サービス一覧

| サービス名 | ポート (Host) | ローカルURL (HTTP) | 備考 / 認証情報 |
| :--- | :--- | :--- | :--- |
| **Apache2** | `80` | - | リバースプロキシ / `*.thales.home` の入口 |
| **AdGuard Home** | `3000`, `53` | `http://adguard.thales.home` | DNSリライト・広告ブロック (Snap) |
| **PostgreSQL 17** | `5432` | - | **Native (TimescaleDB 2.25.2)** / User: `postgres`, `takamiz` / Pass: `postgres` |
| **Stock Market API** | `3002` | `http://stock.thales.home` | 株式データ同期・分析システム (Rust) |
| **Lorenzo** | `3001` | `http://lorenzo.thales.home` | 蔵書管理システム (Docker) |
| **Immich** | `2283` | `http://immich.thales.home` | 自宅フォトサーバー (Docker) |
| **WOL (Web UI)** | `8080` | `http://wol.thales.home` | Wake-on-LAN (legion 起動用) / Docker |
| **Cockpit** | `9090` | `http://cockpit.thales.home` | サーバー管理 Web UI |
| **Munin** | `4949` | `http://munin.thales.home` | リソース監視 (Apache Direct Alias) |
| **WayVNC** | `5900` | - | リモートデスクトップ |
| **Samba** | `139`, `445` | - | ファイル共有 (smbd/nmbd) |
| **PCP** | `44321-3` | - | Performance Co-Pilot (メトリクス収集) |

### 内部専用サービス (Docker Network)
- **immich_postgres**: PostgreSQL 16 (pgvecto-rs) / Port `5432` (内部のみ) / User: `postgres` / Pass: `postgres`
- **immich_redis**: Redis (内部)

## 4. ログ管理 (Logrotate)
各サービスのログは `/etc/logrotate.d/` 以下で以下の通り管理されている。

| ログ対象 | 頻度 | 保存数 | 備考 |
| :--- | :--- | :--- | :--- |
| **Apache2** (`/var/log/apache2/*.log`) | Daily | 14 | `stock_access.log` 等を含む |
| **PostgreSQL** (`/var/log/postgresql/*.log`) | Weekly | 10 | `copytruncate` 設定済み |
| **Stock Market** (`~/stock-market/logs/*.log`) | Daily | 14 | カスタム設定済み |
| **Docker Containers** (`/var/lib/docker/containers/*/*.log`) | Daily | 7 | `copytruncate` 設定済み |
| **Lorenzo** (`~/lorenzo/data/sync.log`) | Daily | 7 | カスタム設定済み |

## 5. 各サービス詳細設定

### Stock Market System
- **構成**: Rust バイナリ (`bin/stock-market`, `bin/server`)
- **Database**: Native PostgreSQL 17 (`stock_market` DB)
- **実行**: `systemd --user` (`stock-server.service`) で管理。`loginctl enable-linger takamiz` 設定済み。

### Immich (Docker)
- **構成**: `immich_server`, `immich_machine_learning`, `immich_postgres`, `immich_redis`
- **認証**: User: `postgres` / Pass: `postgres`

---

## 管理・メンテナンス
- **SSHログイン**: `ssh thales`
- **システム更新**: `sudo apt update && sudo apt upgrade`
- **PostgreSQL 接続確認**: `psql -h 192.168.0.200 -U postgres` (LAN内から)
- **Docker管理**: `docker ps`, `docker compose up -d`
