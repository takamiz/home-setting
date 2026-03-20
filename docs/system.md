# システム環境・ネットワーク構成

> [!NOTE]
> 特定のホストに関する詳細は [PC個別設定: legion](../hosts/legion.md) を参照してください。

## 1. システム環境
- **ホスト名**: `legion`
- **OS**: Ubuntu 26.04 LTS (Questing Quetzal)
- **シェル**: Bash
    - Vimモード有効: `set -o vi`
    - プロンプト: Starship導入済み (`~ ❯` スタイル)
- **ディレクトリ構成**: 英語化済み (`~/Downloads`, `~/Desktop`, `~/Documents` 等)
- **権限**: `takamiz` ユーザーはパスワードなしで `sudo` 実行可能 (`/etc/sudoers.d/takamiz`)

## 2. パッケージ管理
- **形式**: DEB822 (`/etc/apt/sources.list.d/ubuntu.sources`)
- **ミラー**: `http://ftp.riken.jp/Linux/ubuntu/` (理研サーバー)

## 3. SSH / ネットワーク
- **SSH鍵**: Ed25519 (`~/.ssh/id_ed25519`)
- **OpenSSH Server**: インストール済み、UFW で SSH 許可済み
- **Tailscale**: VPN 接続済み（リモートアクセス用）
    - **MagicDNS**: 有効
    - **グローバルDNS + Search Paths**: `home` を search path に登録、AdGuard Home (`100.100.163.37`) をグローバルDNSとして設定
- **DNS / AdGuard Home**:
    - `thales` (192.168.0.200) で AdGuard Home が稼働
    - **DNS 書き換え**: `*.home` を Tailscale IP (`100.100.163.37`) に解決
    - 外出先からでも Tailscale 接続中であれば `http://[サービス].home` でアクセス可能
- **Wake-on-LAN (WOL)**: `legion` ホストで Magic Packet による起動設定済み。詳細は [legion.md](../hosts/legion.md) を参照。
- **接続先サーバー (Host: thales)**
    - **役割**: DNS/自宅サーバー (Raspberry Pi)
    - **LAN IP**: `192.168.0.200`
    - **Tailscale IP**: `100.100.163.37`
    - **User**: `takamiz`
    - **認証**: 鍵認証 (パスワードレス)
    - **Sudo**: `NOPASSWD` 設定済み
    - **稼働中サービス**: Apache2, AdGuard Home (Snap), PostgreSQL 17, Stock Market API (systemd --user), WOL Web UI (systemd --user), Cockpit, Munin, Samba, WayVNC, Node Exporter, Postgres Exporter, PCP (pmcd/pmie/pmlogger/pmproxy), Raspberry Pi Connect (systemd --user)
    - **停止中サービス**: Loki, Prometheus, Promtail — systemd disabled
    - **削除済みサービス** (2026-03-20):
        - Grafana — APT パッケージ削除、Apache VirtualHost 削除
        - Immich — Docker 未インストール、Apache VirtualHost 削除
    - **監視**: PCP (pmlogger) + Munin + Node Exporter + Postgres Exporter で運用。Prometheus/Loki は停止中
    - **Munin カスタムプラグイン** (`/usr/share/munin/plugins/`):
        - `adguard_dns` — DNS応答時間 (warning: 200ms, critical: 1000ms)
        - `adguard_http` — 管理画面HTTP死活 (port 3000)
        - `adguard_dhcp` — DHCPアクティブリース数 (`/var/snap/adguard-home/9005/data/leases.json`, root実行)
        - `rpi_throttle` — 電圧スロットリング・アンダーボルト検知 (root実行)
        - `stock_market` — stock-market/server 死活 (port 3002)
        - `tailscale_peers` — Tailscaleピアオンライン数 (root実行)
        - `smart_nvme_sdb` — sdb NVMe SMART健全性 (温度・spare・使用率・エラー数, `-d sntrealtek`)
        - `postgres_size_ALL` / `postgres_connections_*` — PostgreSQL監視 (`libdbd-pg-perl` 必要, postgres実行)
        - ※ sda (USB HDD) はUSBブリッジがSMARTをブロックするため監視不可
    - **アクセス可能なURL** (LAN `.home` / `*.tk31z.net` / Tailscale 全経路で疎通確認済み):
        - AdGuard Home, Stock Market, Cockpit, WOL, Munin, Router (192.168.0.1)
    - **注意**: RAM 3.7 GB、スワップ 2 GB。Immich のバックグラウンドジョブ起因のスワップ枯渇→ウォッチドッグタイムアウトリセット実績あり (2026-03-17) → Immich は削除済み

## 4. Git 設定
- **User Name**: `takamiz`
- **User Email**: `takamiz@gmail.com`
- **core.editor**: `vim`
