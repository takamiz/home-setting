# Machine Record: kabu

## 1. システム環境

| 項目 | 内容 |
|------|------|
| **ホスト名** | `DESKTOP-2NDF` / `kabu.lan` |
| **LAN IP** | `192.168.0.199` |
| **OS** | Windows 11 Pro 21H2 (Build 22000.2538) |
| **CPU** | Intel Core i7-4790 @ 3.60GHz |
| **RAM** | 約 8 GB |
| **ストレージ** | C: 256 GB SSD (Crucial CT256MX100SSD1) + F: 240 GB SSD (DATA) |
| **NIC** | イーサネット (44:8A:5B:8C:F2:C0) @ 100 Mbps |
| **デフォルトGW** | 192.168.0.1 |
| **DNS** | 192.168.0.200 (thales / AdGuard Home) |
| **用途** | kabu STATION (auカブコム証券) 常駐マシン |

## 2. ユーザー

| ユーザー名 | 有効 | 備考 |
|-----------|------|------|
| `rdpuser` | ✓ | SSH・RDP 用 作業アカウント |
| `delor` | ✓ | — |
| `mieko` | ✓ | — |
| `Administrator` | 無効 | — |

## 3. 稼働中サービス・ポート

| ポート | プロセス | サービス | 備考 |
|--------|---------|---------|------|
| 22/tcp | `sshd` | OpenSSH for Windows 8.1 | 公開鍵認証。known_hosts 登録済み |
| 135/tcp | `svchost` | Microsoft Windows RPC | — |
| 139/tcp | `System` | NetBIOS-SSN | — |
| 3389/tcp | `svchost` | RDP (Remote Desktop Services) | — |
| **8088/tcp** | `nginx` | nginx/1.26.3 → kabu STATION REST API (18080) | stock-swing, stock-db が接続 |
| **8089/tcp** | `nginx` | nginx/1.26.3 → kabu STATION API (18081) | WebSocket / セカンダリ |
| 18080/tcp | `System` (HTTP.sys) | kabu STATION REST API | nginx 経由でのみ外部公開 |
| 18081/tcp | `System` (HTTP.sys) | kabu STATION WebSocket/サブ API | nginx 経由でのみ外部公開 |

> **注意**: 445/tcp (SMB), 5985/5986 (WinRM) はファイアウォールでブロック済み。

## 4. kabu STATION

auカブコム証券が提供する株式売買デスクトップアプリ。REST API と WebSocket を公開している。

- **インストールパス**: `C:\Users\rdpuser\AppData\Local\kabuStation\KabuS.exe`
- **バージョン**: 2026-03-09 更新 (KabuS.exe タイムスタンプ)
- **起動方法**: タスクスケジューラ (rdpuser ログオン時に自動起動)
- **APIポート**: 18080 (REST) / 18081 (WebSocket)

### nginx リバースプロキシ設定

`C:\nginx\nginx-1.26.3\conf\nginx.conf`:

```nginx
worker_processes  1;
events { worker_connections 1024; }
http {
    server {
        listen 8088;
        server_name _;
        location / {
            proxy_pass http://localhost:18080;
            proxy_set_header Host localhost;
        }
    }
    server {
        listen 8089;
        server_name _;
        location / {
            proxy_pass http://localhost:18081;
            proxy_set_header Host localhost;
        }
    }
}
```

LAN 内他マシンから直接 18080/18081 にアクセスできないため、nginx で 8088/8089 にブリッジしている。

### kabu STATION API エンドポイント (確認済み)

| エンドポイント | メソッド | 認証 | 説明 |
|--------------|---------|------|------|
| `/kabusapi/token` | POST | 不要 | APIトークン取得 |
| `/kabusapi/positions` | GET | 必要 | 保有建玉照会 |
| `/kabusapi/orders` | GET | 必要 | 注文照会 |
| `/kabusapi/apisoftlimit` | GET | 必要 | APIレート制限照会 |
| `/kabusapi/websocket` | WS | 必要 | プッシュ通知 (板・約定) |

## 5. インストール済みソフトウェア (主要)

- **開発**: Git, Visual Studio, .NET, Python 2.7, PowerShell
- **ブラウザ**: Google Chrome, Microsoft Edge
- **GPU**: NVIDIA (NVDisplay.ContainerLocalSystem サービス稼働中)
- **日本語入力**: ATOK 33/34 (JustSystems)
- **その他**: IIS / IIS Express, Microsoft SQL Server, TeraTerm, VLC, MPC-HC, Advanced IP Scanner

## 6. 自動化システムとの連携

### stock-swing (`/home/takamiz/repo/stock-swing`)
- `.env`: `KABU_API_BASE_URL=http://192.168.0.199:8088`
- REST API 経由で注文発注・ポジション管理

### stock-db (`/home/takamiz/stock-db`)
- `.env`: `KABU_API_BASE_URL=http://192.168.0.199:8088`
- REST API 経由でトークン取得・板情報 WebSocket 購読・注文・資産・ランキング取得

### stock-trader (`/home/takamiz/repo/stock-trader`)
- `.env`: `KABUCOM_API_BASE=http://localhost:18080` (現在 localhost 向き)
- 本番運用時は `http://192.168.0.199:8088` に変更が必要

## 7. アクセス方法

### SSH
```bash
ssh rdpuser@192.168.0.199   # または ssh rdpuser@kabu.lan
# 鍵: ~/.ssh/id_ed25519
```

### RDP
- ホスト: `192.168.0.199:3389`
- ユーザー: `rdpuser`

## 8. ネットワーク上の注意事項

- SMB (445/tcp): フィルタリング済み → ネットワークドライブ共有不可
- WinRM (5985/5986): フィルタリング済み → PowerShell リモートセッション不可
- Tailscale: 未導入 → LAN 内からのみアクセス可
- nginx: タスクスケジューラ `nginx-autostart` (SYSTEM / OS 起動時) で自動起動
- kabu STATION: タスクスケジューラ `kabuStation-autostart` (rdpuser ログオン時) で自動起動
