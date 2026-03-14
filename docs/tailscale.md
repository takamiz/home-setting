# Tailscale 設定

## 概要

Tailscale を使って外出先からでも自宅サーバー (`thales`) へセキュアにアクセスできる環境を構築している。

## ノード一覧

| ホスト名 | Tailscale IP | 用途 |
| :--- | :--- | :--- |
| `legion` | `100.95.80.2` | メイン開発PC |
| `thales` | `100.100.163.37` | 自宅サーバー |
| `google-pixel-9a` | `100.88.26.89` | スマートフォン |

## DNS 設定

### MagicDNS
- 有効。Tailscale ノード名で相互に名前解決できる。

### Split DNS
- ドメイン `thales.home` のクエリを `100.100.163.37` (thales) の AdGuard Home (port 53) に転送する。
- これにより、外出先でも Tailscale 接続中であればブラウザのリンクから `http://[サービス].thales.home` へアクセスできる。
- 管理コンソールの **DNS → Nameservers → Add nameserver (Restricted to domain)** から設定、または Tailscale API で管理。

```
PATCH https://api.tailscale.com/api/v2/tailnet/-/dns/split-dns
{ "thales.home": ["100.100.163.37"] }
```

### Search Paths
- `thales.home` を登録済み。短縮名でのアクセスが可能。

## DNS 解決の仕組み (legion)

Tailscale は `/etc/resolv.conf` を直接書き換えて DNS を設定する。

```
nameserver 100.100.100.100   # Tailscale MagicDNS
search tail2346aa.ts.net thales.home
```

> **補足**: `resolvconf` 経由の設定は `/usr/sbin/resolvconf` が `resolvectl` のシンボリックリンクであるためインターフェース名不一致エラーが発生するが、実害はない (`/etc/resolv.conf` 直書きにフォールバック済み)。

## 接続確認

```bash
tailscale status         # ノード一覧・接続状態
tailscale netcheck       # 通信品質・DERPサーバー遅延
resolvectl query stock.thales.home  # DNS解決テスト
```

## 管理 API

```bash
# Split DNS 確認
curl -s -u "<API_KEY>:" https://api.tailscale.com/api/v2/tailnet/-/dns/split-dns

# Split DNS 更新
curl -s -X PATCH -u "<API_KEY>:" \
  -H "Content-Type: application/json" \
  -d '{"thales.home":["100.100.163.37"]}' \
  https://api.tailscale.com/api/v2/tailnet/-/dns/split-dns
```
