# エディタ・ツール設定 (Vim一統)

## 1. エディタ
- **Vim (CLI/System Default)**
    - `update-alternatives / VISUAL / EDITOR` 設定済み
    - `crontab`, `visudo`, `git commit` 等で使用
- **Cursor (IDE)**
    - Vim拡張導入済み
- **Zed**
    - モダンエディタ、サブ利用

## 2. AI 開発ツール
- **Gemini CLI**
    - インストール・認証済み
- **Claude Code (CLI)**
    - `@anthropic-ai/claude-code`
    - エディタ連携: `vim`
- **Ollama**
    - ローカル LLM 実行環境
    - モデル: `nemotron-jp`, `llama3.2`, `gemma2:2b`
- **NotebookLM MCP**
    - `notebooklm-mcp-cli` (uv tool でインストール)

## 3. ターミナル & ブラウザ
- **Ghostty**: モダンなターミナルエミュレータ
- **Brave Browser**: メインブラウザ

## 4. その他開発ツール
- **uv**: Python パッケージマネージャ (pip/venv 代替)
- **ethtool**: ネットワークインターフェース設定・WOL構成用
- **Playwright**: UIテスト (`@playwright/test`)
- **cargo-leptos**: Rust Leptos 開発ツール
- **Flameshot**: スクリーンショットツール
- **htop / bashtop**: システムモニタ
