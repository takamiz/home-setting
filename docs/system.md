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
    - **稼働中サービス**: Apache2, AdGuard Home (Snap, port 3004), PostgreSQL 17, Stock Trader API (systemd --user), Health Connect Viewer (systemd --user, port 3002), WOL Web UI (systemd system), Cockpit, Munin, Samba, WayVNC, Node Exporter, Postgres Exporter, Jaeger (systemd --user), PCP (pmcd/pmie/pmlogger/pmproxy)
    - **停止中サービス**: Loki, Prometheus, Promtail, Raspberry Pi Connect — systemd disabled
    - **無効化済みサービス**:
        - `openipmi` — RPi にIPMIハードウェアなし。`mask` 済み (2026-03-28)
        - `nfs-blkmap` / `rpcbind` — NFS未使用のため無効化 (2026-03-20)
    - **削除済みサービス** (2026-03-20):
        - Grafana — APT パッケージ削除、Apache VirtualHost 削除
        - Immich — Docker 未インストール、Apache VirtualHost 削除
        - pgAdmin 4 — 不要のため削除 (2026-04-23)
    - **監視**: PCP (pmlogger) + Munin + Node Exporter + Postgres Exporter で運用。Prometheus/Loki は停止中
    - **Munin カスタムプラグイン** (`/usr/share/munin/plugins/`):
        - `adguard_dns` — DNS応答時間 (warning: 200ms, critical: 1000ms)
        - `adguard_http` — 管理画面HTTP死活 (port 3004)
        - `adguard_dhcp` — DHCPアクティブリース数 (`/var/snap/adguard-home/9005/data/leases.json`, root実行)
        - `rpi_throttle` — 電圧スロットリング・アンダーボルト検知 (root実行)
        - `tailscale_peers` — Tailscaleピアオンライン数 (root実行)
        - `smart_nvme_sdb` — sdb NVMe SMART健全性 (温度・spare・使用率・エラー数, `-d sntrealtek`)
        - `postgres_size_ALL` / `postgres_connections_*` — PostgreSQL監視 (`libdbd-pg-perl` 必要, postgres実行)
        - `munin_switchbot` — SwitchBot Hub2 温湿度・照度・バッテリー監視 (multigraph: 温湿度は部屋別、照度は `switchbot_light` に統合、バッテリーは `switchbot_battery` に統合)
        - `service_health` — 全サービス死活監視 multigraph (root実行): system/user サービス (systemctl) + HTTP/TCP エンドポイント。監視対象: stock-trader, jaeger, adguard 等 (2026-04-23 更新)
        - `multiping` — ルーター(192.168.0.1)・8.8.8.8・1.1.1.1 への RTT・パケットロス監視 (2026-03-29)
        - `apache_accesses` / `apache_processes` / `apache_volume` — Apache アクセス数・プロセス数・転送量 (`libwww-perl` 必要, 2026-03-29)
        - `diskstats` — sda/sdb のみに絞り込み (`env.include_only sda,sdb`、loop デバイス除外, 2026-03-29)
        - ※ sda (USB HDD) はUSBブリッジがSMARTをブロックするため監視不可
        - ※ 設定ファイル: `/etc/munin/plugin-conf.d/local-additions` (diskstats/multiping/apache_* の追加設定)
    - **アクセス可能なURL** (LAN `.home` / `*.tk31z.net` / Tailscale 全経路で疎通確認済み):
        - AdGuard Home, Stock Trader (trader.home), Health Connect Viewer (health.tk31z.net), Cockpit, WOL, Munin, Jaeger (jaeger.home), Router (192.168.0.1)
    - **WOL Web UI**: `/home/takamiz/services/wol` — gunicorn (port 8080)。以前はユーザーサービスだったが、ブート時起動失敗のためシステムサービス (`/etc/systemd/system/wol.service`, `User=takamiz`, `network-online.target` 依存) に移行 (2026-03-20)
    - **Munin テーマ**: Munstrap-Dark (Bootstrap 3ベース) — `/etc/munin/templates/` と `/var/cache/munin/www/static/` に導入
    - **注意**: RAM 3.7 GB、スワップ 2 GB。Immich のバックグラウンドジョブ起因のスワップ枯渇→ウォッチドッグタイムアウトリセット実績あり (2026-03-17) → Immich は削除済み

- **接続先 Windows PC (Host: kabu)**
    - **役割**: kabu STATION (auカブコム証券) 常駐マシン
    - **ホスト名**: `kabu.lan`
    - **LAN IP**: `192.168.0.199`
    - **OS**: Windows
    - **稼働中サービス**: OpenSSH (22), RPC (135), NetBIOS (139), RDP (3389), nginx/1.26.3 → kabu STATION REST API (8088/8089)
    - **kabu STATION API**: `http://192.168.0.199:8088` (stock-swing, stock-db が接続)
    - **Tailscale**: 未導入 (LAN内からのみアクセス可)
    - **詳細**: [hosts/kabu.md](../hosts/kabu.md)

## 4. Docker サービス (legion)

legion 上で Docker Compose により以下のサービスが稼働。

| サービス | ポート | 設定ファイル | 備考 |
|---------|--------|------------|------|
| **GitLab CE** | `8929` (HTTP), `2222` (SSH) | `~/services/gitlab/docker-compose.yml` | 日本語化済み (`default_locale=ja`)、JST (`time_zone=Asia/Tokyo`) |
| **SonarQube** | `9000` | `~/services/sonarqube/docker-compose.yml` | 日本語パック (l10nja 25.5) インストール済み、JST (`TZ=Asia/Tokyo`) |

- **GitLab**: `http://localhost:8929/` — CI/CD, コードレビュー
- **SonarQube**: `http://localhost:9000/sonar/` — コード品質解析 (PostgreSQL on port 5433)
- SonarQube は thales の PostgreSQL (`sonarqube` DB, port 5433) を使用

## 5. Git 設定
- **User Name**: `takamiz`
- **User Email**: `takamiz@gmail.com`
- **core.editor**: `vim`
