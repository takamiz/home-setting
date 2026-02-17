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
1. **ホスト名の設定**:
   ```bash
   sudo hostnamectl set-hostname legion
   sudo vim /etc/hosts # 'legion' に修正
   ```
2. **標準ディレクトリの英語化**:
   `LANG=C xdg-user-dirs-update --force` を実行。
3. **リポジトリミラーの変更 (DEB822形式)**:
   `/etc/apt/sources.list.d/ubuntu.sources` を編集し、理研ミラー (`http://ftp.riken.jp/Linux/ubuntu/`) に設定。
   ```bash
   sudo sed -i 's|http://jp.archive.ubuntu.com/ubuntu/|http://ftp.riken.jp/Linux/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources
   ```
4. **APT Modernization**:
   `sudo apt modernize-sources` を実行して最新形式に移行。
5. **Sudoers 設定**:
   `sudo visudo` で `NOPASSWD` 等を設定（必要に応じて）。

### Step 2: 必須パッケージ & シェル
1. **基本ツールのインストール**:
   `sudo apt update && sudo apt install -y vim curl ca-certificates`
2. **Vim をデフォルトにする**:
   `sudo update-alternatives --config editor` で Vim を選択。
3. **Bash Vim モード設定**:
   `~/.bashrc` に `set -o vi` を追加し `source ~/.bashrc`。
4. **Starship インストール**:
   ```bash
   curl -sS https://starship.rs/install.sh | sudo sh
   # ~/.bashrc に eval "$(starship init bash)" を追加
   ```
5. **Ghostty インストール**:
   公式サイトより DEB パッケージ等をダウンロードしてインストール。

### Step 3: Git & SSH
1. **Git & GitHub CLI 設定**:
   ```bash
   sudo apt install -y git gh
   git config --global user.name "takamiz"
   git config --global user.email "takamiz@gmail.com"
   git config --global core.editor "vim"
   gh auth login
   ```
2. **SSH 鍵作成 & サーバー登録**:
   ```bash
   ssh-keygen -t ed25519 -C "takamiz@gmail.com"
   ssh-copy-id rasp # (rasp は ~/.ssh/config で 192.168.0.200 に設定)
   ```

### Step 4: Docker CE インストール
1. **キーリングとリポジトリ設定**:
   ```bash
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   
   sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
   Types: deb
   URIs: https://download.docker.com/linux/ubuntu
   Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
   Components: stable
   Signed-By: /etc/apt/keyrings/docker.asc
   EOF
   ```
2. **インストール & 権限設定**:
   ```bash
   sudo apt update
   sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   sudo usermod -aG docker $USER
   ```

### Step 5: AI 開発環境 (Antigravity含む)
1. **Node.js/npm**: `sudo apt install npm`
2. **Claude Code**:
   `sudo npm install -g @anthropic-ai/claude-code`
   `claude config set editor vim`
3. **Gemini CLI**:
   `sudo npm install -g @google/gemini-cli`
   `gemini login`
4. **Antigravity**:
   ```bash
   curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
   echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
   sudo apt update && sudo apt install antigravity
   ```
