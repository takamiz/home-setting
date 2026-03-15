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
- **ターミナル**: Ghostty (TokyoNight Storm / JetBrains Mono 12pt)
    - フォント: JetBrains Mono + Noto Sans Mono CJK JP (日本語フォールバック)
    - キーバインド: Windows 派 (Ctrl+Shift+C/V, Ctrl+Shift+T/W, Ctrl+Tab 等)
    - Quick Terminal: `Ctrl+`` でドロップダウン呼び出し
- **Git設定**:
    - User Name: `takamiz`
    - User Email: `takamiz@gmail.com`
    - core.editor: `vim`

## 3. SSH / ネットワーク構成
- **SSH鍵**: Ed25519 (`~/.ssh/id_ed25519`)
- **Wake-on-LAN (WOL)**: 有効 (Magic Packet / `magic`)
- **DNS構成**: 
    - 優先DNS: `192.168.0.200` (thales/AdGuard Home)
    - ドメインルーティング: `.home` ドメインを thales へ強制
- **接続先サーバー (Host: rasp / thales)**:
    - IP: `192.168.0.200`
    - User: `takamiz`
    - 認証: 鍵認証 (パスワードレスログイン設定済み)
    - Sudo: `NOPASSWD` 設定済み (Railsデプロイ/運用用)

## 4. AI 開発環境
- **Gemini CLI**: インストール・認証済み
- **Claude Code (CLI)**: `@anthropic-ai/claude-code` インストール済み
    - エディタ連携: `vim` 設定済み
- **Playwright**: `@playwright/test` インストール済み（ブラウザ依存含む）
- **NotebookLM MCP**: `notebooklm-mcp-cli` (uv tool でインストール)

## 5. ローカル LLM 環境
- **Ollama**: インストール済み（systemd サービス）
    - 登録モデル: `nemotron-jp` (NVIDIA-Nemotron-Nano-9B-v2-Japanese-Q4_K_M), `llama3.2`, `gemma2:2b`
- **llama.cpp**: ソースビルド済み（CUDA 対応: `GGML_CUDA=ON`）
    - パス: `~/Downloads/llama.cpp/build/bin/`
- **CUDA**: `nvidia-cuda-toolkit` インストール済み

## 6. 開発者ツール & ブラウザ
- **ブラウザ**: Brave Browser (インストール済み)
- **IDE**: Cursor (Vim拡張導入済み) / Zed
- **Rust / Leptos**:
    - `rustup`, `cargo-leptos`, `wasm32-unknown-unknown` 導入済み
    - 高速化ツール: `mold` (リンカ), `sccache` (コンパイルキャッシュ) 導入済み
- **uv**: Python パッケージマネージャ (`~/.local/bin/uv`)
- **Flameshot**: スクリーンショットツール
- **htop / bashtop**: システムモニタ

## 7. VPN & リモートアクセス
- **Tailscale**: インストール・接続済み (`tailscale up`)
- **OpenSSH Server**: インストール済み、UFW で SSH 許可済み

## 8. ローカルサービス (Docker)

サービスの compose ファイルは `~/services/<name>/docker-compose.yml` に配置。

| サービス名 | ポート | URL | 備考 |
| :--- | :--- | :--- | :--- |
| **SonarQube Community** | `9000` | `http://localhost:9000` | コード品質解析 / admin:admin (初回変更必須) |

### SonarQube
- **構成**: `~/services/sonarqube/docker-compose.yml`
- **イメージ**: `sonarqube:community` + `postgres:17` (専用コンテナ)
- **起動**: `cd ~/services/sonarqube && docker compose up -d`
- **停止**: `docker compose stop` (データ保持) / `docker compose down` (コンテナ削除)

## 9. 特記事項
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
   `takamiz` ユーザーに対してパスワード不要で `sudo` を実行できるよう設定。
   ```bash
   echo "takamiz ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/takamiz
   sudo chmod 0440 /etc/sudoers.d/takamiz
   ```

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
5. **JetBrains Mono フォントインストール**:
   ```bash
   cd /tmp
   curl -sLO https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
   unzip -qo JetBrainsMono-2.304.zip -d JetBrainsMono
   mkdir -p ~/.local/share/fonts
   cp JetBrainsMono/fonts/ttf/*.ttf ~/.local/share/fonts/
   fc-cache -f
   ```
6. **Ghostty インストール & 設定**:
   公式サイトより DEB パッケージ等をダウンロードしてインストール。
   設定ファイル: `~/.config/ghostty/config`
   ```
   # テーマ・フォント
   theme = dark:TokyoNight Storm,light:TokyoNight Day
   font-family = JetBrains Mono
   font-family = Noto Sans Mono CJK JP
   font-size = 12

   # 日本語入力 (IBus)
   grapheme-width-method = unicode
   selection-clear-on-typing = false
   ```

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
    # 権限エラーが出る場合は以下を実行
    sudo chmod 666 /var/run/docker.sock
    
    # docker-compose (ハイフンあり) のシンボリックリンク作成
    sudo ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose
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

### Step 6: その他ツール & Rust 開発環境
1. **Brave Browser**:
   `curl -fsS https://dl.brave.com/install.sh | sh`
2. **Playwright**:
   ```bash
   npm install -D @playwright/test @types/node
   npx playwright install --with-deps chromium
   ```
3. **Zed エディタ**:
   `curl -f https://zed.dev/install.sh | sh`
4. **uv (Python パッケージマネージャ)**:
   `curl -LsSf https://astral.sh/uv/install.sh | sh`
5. **ユーティリティ**:
   `sudo apt install -y flameshot htop bashtop`
6. **Rust & Leptos インストール**:
   ```bash
   # Rust
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
   source $HOME/.cargo/env
   rustup target add wasm32-unknown-unknown
   
   # Leptos & Cross
   cargo install cargo-leptos
   cargo install cross --git https://github.com/cross-rs/cross
   
   # 高速化ツール (mold, sccache)
   sudo apt install -y mold sccache
   # ~/.bashrc に以下を追加
   # export RUSTC_WRAPPER=sccache
   # export RUSTFLAGS="-C link-arg=-fuse-ld=mold"
   ```
### Step 7: DNS 設定 (内部ドメイン対応)
1. **DNS サーバーの指定**:
   ```bash
   sudo resolvectl dns enp4s0 192.168.0.200
   ```
2. **ドメインルーティングの設定**:
   `.home` ドメイン（および既存ドメイン）を明示的に指定。
   ```bash
   sudo resolvectl domain enp4s0 flets-east.jp iptvf.jp ~home
   ```
3. **キャッシュのクリア**:
   ```bash
   sudo resolvectl flush-caches
   ```

### Step 8: Tailscale & OpenSSH Server
1. **Tailscale インストール & 接続**:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up
   ```
2. **OpenSSH Server**:
   ```bash
   sudo apt install -y openssh-server
   sudo systemctl enable --now ssh
   sudo ufw allow ssh
   ```

### Step 9: ローカル LLM 環境 (Ollama / llama.cpp)
1. **Ollama インストール**:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
2. **カスタムモデル登録 (例: Nemotron JP)**:
   ```bash
   cd ~/Downloads
   cat <<EOF > Modelfile
   FROM ./NVIDIA-Nemotron-Nano-9B-v2-Japanese-Q4_K_M.gguf
   EOF
   ollama create nemotron-jp -f Modelfile
   ```
3. **llama.cpp ビルド (CUDA)**:
   ```bash
   sudo apt install -y cmake nvidia-cuda-toolkit
   git clone https://github.com/ggerganov/llama.cpp
   cd llama.cpp
   cmake -B build -DGGML_CUDA=ON
   cmake --build build --config Release -j $(nproc)
   ```

### Step 10: Wake-on-LAN (WOL) 設定
1. **BIOS 設定**:
   PC 起動時に BIOS (F2/Del) に入り、`Wake on LAN` または `Power On By PCI-E` を **Enabled** に設定。
2. **ethtool のインストール**:
   `sudo apt install -y ethtool`
3. **WOL の有効化 (Magic Packet)**:
   ```bash
   sudo ethtool -s enp4s0 wol g
   ```
4. **永続化 (NetworkManager / Netplan)**:
   NetworkManager を使用している場合:
   ```bash
   sudo nmcli connection modify netplan-enp4s0 802-3-ethernet.wake-on-lan magic
   ```
   または `/etc/netplan/00-installer-config.yaml` の `enp4s0` セクションに `wakeonlan: true` を追記して `sudo netplan apply` を実行。
