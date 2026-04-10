# Home Setting

自宅の開発環境、システム構成、および進行中のプロジェクトを管理・記録するリポジトリです。

## 概要

このリポジトリは、Ubuntu (legion) を中心とした開発環境の構築手順、プロジェクトの進捗状況、および各種ツール設定をドキュメント化し、継続的な改善と再現性を確保することを目的としています。

## クイックアクセス

- [システム環境・ネットワーク](./docs/system.md)
- [Tailscale 設定](./docs/tailscale.md)
- [Cloudflare 設定](./docs/cloudflare.md)
- [エディタ・ツール設定 (Vim/AI)](./docs/tools.md)
- [進行中プロジェクト一覧](./docs/projects.md)
- [PC個別設定: legion](./hosts/legion.md)
- [PC個別設定: thales](./hosts/thales.md)

## サービス一覧 (thales) - Tailscale 経由でアクセス可能

| サービス | LAN (`*.home`) | HTTPS (`*.tk31z.net`) | Tailscale (`thales.tail2346aa.ts.net`) |
| :--- | :--- | :--- | :--- |
| 📡 AdGuard Home | [adguard.home](http://adguard.home) | [adguard.tk31z.net](https://adguard.tk31z.net) | [/adguard](https://thales.tail2346aa.ts.net/adguard) |
| 📈 Stock Market | [stock.home](http://stock.home) | [stock.tk31z.net](https://stock.tk31z.net) | [/stock](https://thales.tail2346aa.ts.net/stock) |
| 💹 Stock Trader | [trader.home](http://trader.home) | [trader.tk31z.net](https://trader.tk31z.net) | [/trader](https://thales.tail2346aa.ts.net/trader) |
| 📉 Stock Swing | [swing.home](http://swing.home) | [swing.tk31z.net](https://swing.tk31z.net) | [/swing](https://thales.tail2346aa.ts.net/swing) |
| 🗄️ Stock DB | [stock-db.home](http://stock-db.home) | [stock-db.tk31z.net](https://stock-db.tk31z.net) | [/stock-db](https://thales.tail2346aa.ts.net/stock-db) |
| 💻 Cockpit | [cockpit.home](http://cockpit.home) | [cockpit.tk31z.net](https://cockpit.tk31z.net) | [/cockpit](https://thales.tail2346aa.ts.net/cockpit) |
| ⚡ WOL | [wol.home](http://wol.home) | [wol.tk31z.net](https://wol.tk31z.net) | [/wol](https://thales.tail2346aa.ts.net/wol) |
| 🔧 Router | [router.home](http://router.home) | [router.tk31z.net](https://router.tk31z.net) | [/router](https://thales.tail2346aa.ts.net/router) |
| 📰 Munin | [munin.home](http://munin.home) | [munin.tk31z.net](https://munin.tk31z.net) | [/munin](https://thales.tail2346aa.ts.net/munin) |
| 🔍 Jaeger | [jaeger.home](http://jaeger.home) | [jaeger.tk31z.net](https://jaeger.tk31z.net) | [/jaeger](https://thales.tail2346aa.ts.net/jaeger) |
| 🐘 pgAdmin | [pgadmin.home](http://pgadmin.home) | [pgadmin.tk31z.net](https://pgadmin.tk31z.net) | [/pgadmin](https://thales.tail2346aa.ts.net/pgadmin) |

> `*.home`: LAN内アクセス。`*.tk31z.net`: Let's Encrypt HTTPS (Tailscale接続時)。`thales.tail2346aa.ts.net`: Tailscale Serve 経由 HTTPS。

---

## 基本情報 (2026-03-08 更新)

- **OS**: Ubuntu 26.04 LTS (Questing Quetzal)
- **Hostname**: `legion` (100.95.80.2)
- **Tailscale DNS**: `*.home` -> `100.100.163.37` (thales)
- **WOL**: 有効 (Magic Packet)
- **Shell**: Bash (+ Starship)
- **Primary Editor**: Vim (CLI) / Cursor (IDE)
- **Main Languages**: Rust, Python, Ruby, PHP
