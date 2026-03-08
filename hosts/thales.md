# Machine Record: thales

## 1. システム環境
- **ホスト名**: `thales`
- **OS**: Debian GNU/Linux 13 (trixie)
- **アーキテクチャ**: `arm64` (Raspberry Pi)
- **カーネル**: Linux 6.12.62+rpt-rpi-v8

## 2. SSH / ネットワーク構成
- **接続先エイリアス**: `thales` (または `rasp`)
- **IPアドレス**: `192.168.0.200`
- **ユーザー**: `takamiz`
- **認証**: 鍵認証 (`~/.ssh/id_ed25519`)
- **Sudo**: `NOPASSWD` 設定済み

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

## 4. 各サービス詳細設定

### Stock Market System
- **ディレクトリ**: `~/stock-market`
- **主要構成**:
    - **Backend**: Rust バイナリ (`bin/stock-market`, `bin/server`)
    - **Database**: Native PostgreSQL 17 (`stock_market` データベースを使用)
    - **Data**: `data/archives` に CSV/GZ 形式で株価データを保持
- **Domain**: `stock.thales.home` (Port 3002 へプロキシ)

### Immich (Docker)
- **構成**: `immich_server`, `immich_machine_learning`, `immich_postgres`, `immich_redis`
- **認証**: User: `postgres` / Pass: `postgres`
- **Domain**: `immich.thales.home` (Port 2283 へプロキシ)

---

## DNS / リバースプロキシ構成詳細

### AdGuard Home (DNSリライト)
- `*.thales.home` 形式のドメインをすべて `192.168.0.200` (`thales`) に解決。
- 設定ファイル: `/var/snap/adguard-home/current/AdGuardHome/AdGuardHome.yaml`

### Apache2 (リバースプロキシ)
- 設定ディレクトリ: `/etc/apache2/sites-available/`
- 各サービスごとに `.conf` ファイルを作成し、`ProxyPass` で内部ポートへ転送。
- `ServerName` はすべて `*.thales.home` 形式に統一。

## 管理・メンテナンス
- **SSHログイン**: `ssh thales`
- **システム更新**: `sudo apt update && sudo apt upgrade`
- **PostgreSQL 接続確認**: `psql -h 192.168.0.200 -U postgres` (LAN内から)
- **Docker管理**: `docker ps`, `docker compose up -d`
