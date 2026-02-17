# Machine Record: legion

## 1. システム環境
- **ホスト名**: `legion`
- **OS**: Ubuntu 26.04 LTS (Questing Quetzal)
- **シェル**: Bash (Vimモード有効: `set -o vi`)
- **プロンプト**: Starship導入済み (`~ ❯` スタイル)
- **パッケージ管理**: 
    - 形式: DEB822 (`/etc/apt/sources.list.d/ubuntu.sources`)
    - ミラー: `http://ftp.riken.jp/Linux/ubuntu/` (理研サーバー)
- **ディレクトリ構成**: 英語化済み (`~/Downloads`, `~/Desktop`, `~/Documents` 等)

## 2. エディタ・ツール設定 (Vim一統)
- **システムデフォルト**: `vim` (update-alternatives / VISUAL / EDITOR 設定済み)
    - `crontab`, `visudo`, `git commit` 等はすべて Vim で起動
- **IDE**: Cursor (Vim拡張導入済み)
- **ターミナル**: Ghostty
- **Git設定**:
    - User Name: `takamiz`
    - User Email: `takamiz@gmail.com`
    - core.editor: `vim`

## 3. SSH / ネットワーク構成
- **SSH鍵**: Ed25519 (`~/.ssh/id_ed25519`)
- **接続先サーバー (Host: rasp)**:
    - IP: `192.168.0.200`
    - User: `takamiz`
    - 認証: 鍵認証 (パスワードレスログイン設定済み)
    - Sudo: `NOPASSWD` 設定済み (Railsデプロイ/運用用)

## 4. AI 開発環境
- **Gemini CLI**: インストール・認証済み
- **Claude Code (CLI)**: `@anthropic-ai/claude-code` インストール済み
    - エディタ連携: `vim` 設定済み

## 5. 特記事項
- 特定のクレデンシャルやライブラリ依存（OpenSSL等）については、必要に応じて各CLIへのプロンプトで個別指示を行う。

---

## 再セットアップ手順 (Setup / Re-setup)

### Step 1: OS 基本設定
1. **リポジトリミラーの変更**:
   `/etc/apt/sources.list.d/ubuntu.sources` を編集し、理研ミラー (`http://ftp.riken.jp/Linux/ubuntu/`) に設定。
2. **標準ディレクトリの英語化**:
   `LANG=C xdg-user-dirs-update --force` を実行。

### Step 2: 開発ツール & シェル
1. **Vim のインストールとデフォルト化**:
   `sudo apt install vim`
   `sudo update-alternatives --config editor` で Vim を選択。
2. **Bash Vim モード設定**:
   `~/.bashrc` に `set -o vi` を追加。
3. **Starship インストール**:
   公式のインストールスクリプトを実行し、`~/.bashrc` に `eval "$(starship init bash)"` を追加。
4. **Ghostty インストール**:
   公式サイトより DEB パッケージ等をダウンロードしてインストール。

### Step 3: Git & SSH
1. **Git 設定**:
   ```bash
   git config --global user.name "takamiz"
   git config --global user.email "takamiz@gmail.com"
   git config --global core.editor "vim"
   ```
2. **SSH 鍵作成**:
   `ssh-keygen -t ed25519 -C "takamiz@gmail.com"`

### Step 4: AI 開発環境
1. **Gemini CLI**: `gemini login` で認証。
2. **Claude Code**:
   `npm install -g @anthropic-ai/claude-code`
   `claude config set editor vim`

### Step 5: ネットワーク & サーバー接続
1. `~/.ssh/config` に `rasp` の設定を追加 (IP: 192.168.0.200)。
2. `ssh-copy-id rasp` で公開鍵を転送。
