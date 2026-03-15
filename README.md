# Home Setting

自宅の開発環境、システム構成、および進行中のプロジェクトを管理・記録するリポジトリです。

## 概要

このリポジトリは、Ubuntu (legion) を中心とした開発環境の構築手順、プロジェクトの進捗状況、および各種ツール設定をドキュメント化し、継続的な改善と再現性を確保することを目的としています。

## クイックアクセス

- [システム環境・ネットワーク](./docs/system.md)
- [Tailscale 設定](./docs/tailscale.md)
- [エディタ・ツール設定 (Vim/AI)](./docs/tools.md)
- [進行中プロジェクト一覧](./docs/projects.md)
- [PC個別設定: legion](./hosts/legion.md)
- [PC個別設定: thales](./hosts/thales.md)

## サービス一覧 (thales) - Tailscale 経由でアクセス可能

### ショートURL（`*.home` / LAN + Tailscale 両対応）

- 📡 [AdGuard Home](http://adguard.home) - 広告ブロック・DNS設定
- 🖼️ [Immich](http://immich.home) - フォトサーバー
- 📊 [Grafana](http://grafana.home) - システム監視
- 📈 [Stock Market](http://stock.home) - 株価分析
- 📚 [Lorenzo](http://lorenzo.home) - 蔵書管理
- 💻 [Cockpit](http://cockpit.home) - サーバー管理
- ⚡ [WOL (Web UI)](http://wol.home) - legion 起動

### Tailscale Serve URL（HTTPS / Tailscale 接続時のみ）

- 📡 [AdGuard Home](https://thales.tail2346aa.ts.net/adguard)
- 🖼️ [Immich](https://thales.tail2346aa.ts.net/immich)
- 📊 [Grafana](https://thales.tail2346aa.ts.net/grafana)
- 📈 [Stock Market](https://thales.tail2346aa.ts.net/stock)
- 📚 [Lorenzo](https://thales.tail2346aa.ts.net/lorenzo)
- 💻 [Cockpit](https://thales.tail2346aa.ts.net/cockpit)
- ⚡ [WOL (Web UI)](https://thales.tail2346aa.ts.net/wol)
- 📉 [Munin](https://thales.tail2346aa.ts.net/munin)

---

## 基本情報 (2026-03-08 更新)

- **OS**: Ubuntu 26.04 LTS (Questing Quetzal)
- **Hostname**: `legion` (100.95.80.2)
- **Tailscale DNS**: `*.home` -> `100.100.163.37` (thales)
- **WOL**: 有効 (Magic Packet)
- **Shell**: Bash (+ Starship)
- **Primary Editor**: Vim (CLI) / Cursor (IDE)
- **Main Languages**: Rust, Python, Ruby, PHP
