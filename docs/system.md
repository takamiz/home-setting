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
    - **役割**: Railsデプロイ/運用/DNS/メディアサーバー (Raspberry Pi)
    - **LAN IP**: `192.168.0.200`
    - **Tailscale IP**: `100.100.163.37`
    - **User**: `takamiz`
    - **認証**: 鍵認証 (パスワードレス)
    - **Sudo**: `NOPASSWD` 設定済み
    - **稼働中サービス**: AdGuard Home, tailscaled, stock-market/server, PCP (pmlogger), Munin, Samba, postgres (ローカル)
    - **停止中サービス (メモリ節約のため無効化, 2026-03-17)**:
        - Immich (server / ML / postgres / redis) — Docker `restart: "no"`
        - Loki, Grafana, Prometheus, Promtail — systemd disabled
        - prometheus-node-exporter, prometheus-postgres-exporter — systemd disabled
        - docker, containerd — systemd disabled (Immich停止中のため)
        - lightdm, bluetooth, cups, cups-browsed, colord, avahi-daemon, ModemManager, nfs-blkmap — 不要サービス
    - **監視**: PCP (pmlogger) + Munin で運用。Prometheus/Grafana/Loki は停止中
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
    - **注意**: RAM 3.7 GB、スワップ 2 GB だがメモリ逼迫しやすい。Immich のバックグラウンドジョブがトリガーとなりスワップ枯渇→ウォッチドッグタイムアウトでリセットした実績あり (2026-03-17)

## 4. Git 設定
- **User Name**: `takamiz`
- **User Email**: `takamiz@gmail.com`
- **core.editor**: `vim`
