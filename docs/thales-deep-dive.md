# thales 詳細設定レポート (Reconstruction & Management Guide)

このレポートは、`thales` (Raspberry Pi 4/5) をゼロから再構築する際、または設定を詳細に把握するための技術リファレンスです。

## 1. 基本システム (OS & Hardware)
- **OS**: Debian GNU/Linux 13 (trixie) - Raspberry Pi OS 64-bit (Testing)
- **Kernel**: 6.12.x-rpt-rpi-v8
- **Hostname**: `thales` (IP: `192.168.0.200`)
- **Storage**:
  - `/dev/sdb2` (235G): ルートパーティション (`ext4`)
  - `/dev/sda1` (3.7T): 外部USB-HDD (`xfs`) - `/mnt/usb-hdd` にマウント
  - **ZRAM**: `zram0` (swap用) が有効化されており、メモリ不足を補っている

## 2. ネットワーク & DNS
- **IP設定**: `192.168.0.200/24` 固定（ルーター側または `NetworkManager` で設定）。
- **DNS (AdGuard Home)**:
  - Snap経由で導入。
  - **DNSリライト**: `*.thales.home` を `192.168.0.200` に向ける設定。
  - 設定ファイル: `/var/snap/adguard-home/current/AdGuardHome/AdGuardHome.yaml`
- **Tailscale**: VPNメッシュに参加。`resolv.conf` は Tailscale によって管理されている。

## 3. パッケージリポジトリ (APT Sources)
再構築時に以下のリポジトリ追加が必要：
- **Docker**: `https://download.docker.com/linux/debian trixie`
- **PostgreSQL**: `https://apt.postgresql.org/pub/repos/apt trixie-pgdg`
- **TimescaleDB**: `https://packagecloud.io/timescale/timescaledb/debian/ bookworm` (Trixie未対応のため互換性利用)
- **Tailscale**: `https://pkgs.tailscale.com/stable/debian trixie`
- **Speedtest**: `https://packagecloud.io/ookla/speedtest-cli/debian trixie`

## 4. データベース (PostgreSQL 17 Native)
- **構成**: PostgreSQL 17 + TimescaleDB 2.25.x
- **最適化**: `timescaledb-tune` により以下が設定済み
  - `shared_buffers`: ~950MB (メモリ約1/4)
  - `effective_cache_size`: ~2.8GB
- **接続**: 
  - `listen_addresses = '*'`
  - `pg_hba.conf`: `192.168.0.0/24` からの `scram-sha-256` 接続を許可
  - 主要ユーザー: `postgres`, `takamiz` (Pass: `postgres`)
  - 主要DB: `stock_market`, `immich` (Docker用とは別)

## 5. Webサービス (Apache2 Reverse Proxy)
- **役割**: 各サービスへの `*.thales.home` ドメインによる入り口。
- **設定場所**: `/etc/apache2/sites-available/*.conf`
- **主要プロキシ定義**:
  - `stock.thales.home` -> `localhost:3002`
  - `immich.thales.home` -> `localhost:2283`
  - `lorenzo.thales.home` -> `localhost:3001`
  - `wol.thales.home` -> `localhost:8080`
  - `adguard.thales.home` -> `localhost:3000`
  - `cockpit.thales.home` -> `localhost:9090`

## 6. アプリケーション実行 (Systemd User Services)
`takamiz` ユーザーの `systemd` ユニットとして管理されている：
- **`stock-server.service`**: `~/stock-market/bin/server` を実行。ポート `3002`。
- **管理コマンド**: `systemctl --user status stock-server.service`
- **自動起動設定**: `loginctl enable-linger takamiz` が実行済み（ログアウト後もサービス継続）。

## 7. ログ管理 (Logrotate)
- **場所**: `/etc/logrotate.d/`
- **独自設定**:
  - `stock-market`: 日次ローテーション、14世代保存、圧縮。
  - `docker-containers`: Dockerコンテナのログサイズ肥大化防止 (`copytruncate`)。
  - `lorenzo`: 日次ローテーション、7世代保存。
