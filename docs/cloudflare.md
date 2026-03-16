# Cloudflare 設定

## 概要

`tk31z.net` のDNS管理をCloudflareで行っている。
Let's Encrypt のワイルドカード証明書取得（DNS-01チャレンジ）に利用。

---

## アカウント情報

- **メールアドレス**: `takamiz@gmail.com`
- **管理画面**: `https://dash.cloudflare.com`
- **プラン**: Free

---

## ドメイン

| ドメイン | Zone ID | ステータス |
| :--- | :--- | :--- |
| `tk31z.net` | `2c5f2d72e7c74f55e2bd8e31d0302cc8` | Active |

### ネームサーバー（お名前.comで設定）

```
dane.ns.cloudflare.com
rafe.ns.cloudflare.com
```

---

## DNSレコード

| タイプ | 名前 | 内容 | 用途 |
| :--- | :--- | :--- | :--- |
| TXT | `tk31z.net` | `google-site-verification=...` | Google Search Console 所有権確認 |

> `*.tk31z.net` のAレコードはCloudflareには登録しない。AdGuard HomeのDNSリライト（`*.tk31z.net` → `192.168.0.200`）で解決するため、Tailscaleネットワーク内専用。

---

## APIトークン

- **用途**: acme.sh による Let's Encrypt DNS-01 チャレンジ（TXTレコードの自動追加・削除）
- **テンプレート**: Edit zone DNS
- **スコープ**: `tk31z.net` のみ
- **保存場所**: `~/.acme.sh/account.conf` (`SAVED_CF_Token`)

```bash
# Claude Code から使う場合（acme.shの設定から読み込み）
CF_TOKEN=$(grep SAVED_CF_Token ~/.acme.sh/account.conf | cut -d"'" -f2)

# DNS レコード一覧確認
curl -s "https://api.cloudflare.com/client/v4/zones/2c5f2d72e7c74f55e2bd8e31d0302cc8/dns_records" \
  -H "Authorization: Bearer ${CF_TOKEN}" | jq '.result[] | {type, name, content}'

# TXT レコード追加
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/2c5f2d72e7c74f55e2bd8e31d0302cc8/dns_records" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"type":"TXT","name":"tk31z.net","content":"値","ttl":120}'
```

> **注意**: Cloudflare API は `/dns/records` ではなく `/dns_records`（アンダースコア）を使用する。

---

## お名前.com との関係

- **ドメイン登録**: お名前.com（ログインID: `6491241`）
- **DNS管理**: Cloudflare に移管済み（ネームサーバーをCloudflareに変更）
- お名前.com 側では DNS レコードは管理しない

---

## Let's Encrypt 証明書との連携

acme.sh が Cloudflare API を使って DNS-01 チャレンジを自動処理する。

```bash
# 証明書の手動更新
CF_Token=$(grep SAVED_CF_Token ~/.acme.sh/account.conf | cut -d"'" -f2) \
  ~/.acme.sh/acme.sh --renew -d tk31z.net --force
```

詳細は [thales.md](../hosts/thales.md) の「SSL証明書」セクションを参照。
