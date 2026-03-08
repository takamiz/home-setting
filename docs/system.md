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
- **Wake-on-LAN (WOL)**: `legion` ホストで Magic Packet による起動設定済み。詳細は [legion.md](../hosts/legion.md) を参照。
- **接続先サーバー (Host: rasp / thales)**
    - **役割**: Railsデプロイ/運用用
    - **IP**: `192.168.0.200`
    - **User**: `takamiz`
    - **認証**: 鍵認証 (パスワードレス)
    - **Sudo**: `NOPASSWD` 設定済み

## 4. Git 設定
- **User Name**: `takamiz`
- **User Email**: `takamiz@gmail.com`
- **core.editor**: `vim`
