# Tailscale 設定

## 概要

Tailscale を使って外出先からでも自宅サーバー (`thales`) へセキュアにアクセスできる環境を構築している。

## ノード一覧

| ホスト名 | Tailscale IP | OS | 用途 |
| :--- | :--- | :--- | :--- |
| `legion` | `100.95.80.2` | Ubuntu 26.04 LTS (x86_64) | メイン開発PC |
| `thales` | `100.100.163.37` | Debian 13 trixie (arm64) | 自宅サーバー (Raspberry Pi) |
| `google-pixel-9a` | `100.88.26.89` | Android | スマートフォン |

---

## DNS 設定

### MagicDNS
- 有効。Tailscale ノード名で相互に名前解決できる (`thales.tail2346aa.ts.net` 等)。

### グローバルDNS + Search Paths（現在の構成）
- `100.100.163.37` (thales の AdGuard Home) を **グローバルDNSサーバー**として登録。
- Tailscale の **Search Paths** に `home` を登録済み。
- 外出先でも Tailscale 接続中であればブラウザから `http://[サービス].home` へアクセス可能。
- AdGuard Home が `*.home` / `*.tk31z.net` → `192.168.0.200` に解決する。
- `*.tk31z.net` は HTTPS対応（Let's Encrypt ワイルドカード証明書）。

> **補足**: Split DNS（ドメイン限定転送）ではなく、グローバルDNSサーバーとして設定しているため、すべてのクエリが AdGuard Home を経由する。

### Search Paths
- `home` を登録済み。`stock.home` のように短縮名でのアクセスが可能。

---

## ホスト別設定

### legion (Ubuntu 26.04 LTS)

#### インストール & 接続

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

#### DNS 解決の仕組み

Tailscale は `/etc/resolv.conf` を直接書き換えて DNS を設定する。

```
nameserver 100.100.100.100   # Tailscale MagicDNS
search tail2346aa.ts.net home
```

> **補足**: `resolvconf` 経由の設定は `/usr/sbin/resolvconf` が `resolvectl` のシンボリックリンクであるためインターフェース名不一致エラーが発生するが、実害はない (`/etc/resolv.conf` 直書きにフォールバック済み)。

#### Tailscale サービス管理

```bash
sudo systemctl status tailscaled    # サービス状態確認
sudo systemctl enable tailscaled    # 自動起動有効化
sudo systemctl restart tailscaled   # 再起動
```

#### 接続確認コマンド

```bash
tailscale status                           # ノード一覧・接続状態
tailscale netcheck                         # 通信品質・DERPサーバー遅延
resolvectl query stock.home                # DNS解決テスト
ping thales                                # MagicDNS 疎通確認
```

---

### thales (Debian 13 trixie / Raspberry Pi)

#### APT リポジトリ設定

```bash
curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.noarmor.gpg \
  | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.tailscale-keyring.list \
  | sudo tee /etc/apt/sources.list.d/tailscale.list
```

#### インストール & 接続

```bash
sudo apt update && sudo apt install -y tailscale
sudo tailscale up
```

#### Tailscale サービス管理

```bash
sudo systemctl status tailscaled    # サービス状態確認
sudo systemctl enable tailscaled    # 自動起動有効化
```

#### AdGuard Home との連携

- Tailscale グローバルDNSサーバーとして `100.100.163.37:53` (AdGuard Home) が設定されている。
- AdGuard Home の DNS リライトで各ドメインを `192.168.0.200` (LAN IP) に解決。

**DNS リライト設定 (AdGuard Home 管理画面 → フィルタ → DNS リライト)**:

| ドメインパターン | 解決先 IP | 用途 |
| :--- | :--- | :--- |
| `*.home` | `192.168.0.200` | LAN内サービスアクセス |
| `thales` | `192.168.0.200` | thales ホスト名解決 |
| `router.home` | `192.168.0.1` | ルーター管理画面 |
| `*.tk31z.net` | `192.168.0.200` | HTTPS対応ドメイン |

> **ポイント**: `*.tk31z.net` は Apache が `192.168.0.200:443` で HTTPS 終端。Tailscale Serve が `100.100.163.37:443` を使用するため、Apache は LAN IP のみで Listen している。

#### 接続確認コマンド

```bash
tailscale status         # ノード一覧・接続状態
tailscale ip -4          # 自ノードのTailscale IPを確認
```

---

## Tailscale 管理 API

APIキーは環境変数やパスワードマネージャーで管理する。ドキュメントには記載しない。

```bash
# 環境変数にセット
export TS_API_KEY="<API_KEY>"

# グローバルDNS 確認
curl -s -u "${TS_API_KEY}:" \
  https://api.tailscale.com/api/v2/tailnet/-/dns/nameservers

# グローバルDNS 更新 (AdGuard Home を向ける)
curl -s -X POST -u "${TS_API_KEY}:" \
  -H "Content-Type: application/json" \
  -d '{"dns":["100.100.163.37"]}' \
  https://api.tailscale.com/api/v2/tailnet/-/dns/nameservers

# Search Paths 確認
curl -s -u "${TS_API_KEY}:" \
  https://api.tailscale.com/api/v2/tailnet/-/dns/searchpaths

# Search Paths 更新
curl -s -X POST -u "${TS_API_KEY}:" \
  -H "Content-Type: application/json" \
  -d '{"searchPaths":["home"]}' \
  https://api.tailscale.com/api/v2/tailnet/-/dns/searchpaths

# ノード一覧確認
curl -s -u "${TS_API_KEY}:" \
  https://api.tailscale.com/api/v2/tailnet/-/devices | jq '.devices[] | {name, addresses}'
```

### APIキーの保管場所

- APIキーは Tailscale 管理コンソール (**Settings → Keys**) で発行・管理する。
- ローカルでは `~/.config/tailscale/api_key` に保存し、`chmod 600` で保護する。

```bash
# ~/.bashrc に追記（ターミナルでの手動操作用）
export TS_API_KEY="$(cat ~/.config/tailscale/api_key)"
```

### Claude Code からAPIキーを使う場合

Claude Code が起動する Bash は毎回新規シェルのため、`~/.bashrc` は自動で読み込まれない。
APIキーを使う Bash コマンドは以下のように明示的にファイルから読み込む：

```bash
TS_API_KEY=$(cat ~/.config/tailscale/api_key) && curl -s -u "${TS_API_KEY}:" \
  https://api.tailscale.com/api/v2/tailnet/-/dns/nameservers
```

または Claude に「`~/.config/tailscale/api_key` のキーを使って」と指示すれば対応できる。

---

## トラブルシューティング

### DNS が機能しない場合

```bash
# Tailscale DNS 設定を確認
tailscale debug dns status

# resolv.conf を確認
cat /etc/resolv.conf

# AdGuard Home が応答しているか確認
dig @100.100.163.37 stock.home
```

### Tailscale 接続が切れた場合

```bash
sudo tailscale up         # 再接続
sudo systemctl restart tailscaled
```
