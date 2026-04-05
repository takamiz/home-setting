# 進行中のプロジェクト & 技術スタック

## プロジェクト一覧

### Project Laura
- **概要**: バーコードスキャンによる購入日予測アプリ
- **技術**: Rust / Wasm

### Project Lorenzo (Enzo) → stock-* シリーズへ発展
- **概要**: J-Quants APIを利用した株価スクリーニングアプリが発展し、以下の4リポジトリで構成するアルゴリズム取引システムへ拡張。

#### stock-market（データ基盤）
- **概要**: J-Quants API V2 から全上場銘柄（約4,000）の株価・財務データを取得し TimescaleDB に蓄積。NGA（Next-Gen Analysis）として TDA・非線形動力学的な市場分析も担う。
- **パス**: `/home/takamiz/repo/stock-market`
- **バージョン**: v0.3.0
- **技術**: Rust / sqlx / TimescaleDB / Polars / axum / Leptos (WASM) / Docker / GitLab CI/CD / SonarQube

#### stock-trader（デイトレード）
- **概要**: 朝スクリーニング → ザラ場中の自動エントリ/エグジット（当日クローズ）。kabu STATION またはペーパーモードで稼働。
- **パス**: `/home/takamiz/repo/stock-trader`
- **戦略**: SL -3% / TP +5%。OOS実績 +4.6% / 15ヶ月、Sharpe 0.98。
- **技術**: Rust / sqlx / axum / Leptos (WASM) / systemd タイマー（日次バッチ）

#### stock-swing（スウィングトレード）
- **概要**: RSI + MA60 + プルバック スコアリングによる 3〜20 日保有のスウィングトレード。
- **パス**: `/home/takamiz/repo/stock-swing`
- **戦略**: SL -5% / TP +10% + トレーリングストップ 5%。OOS実績 +6.21% / 15ヶ月、Sharpe 0.93。
- **技術**: Rust / sqlx / axum / Leptos (WASM)

#### stock-db（kabu STATION 連携・DB記録）
- **概要**: kabu STATION REST API に接続し、板情報・注文・資産・ランキングをリアルタイムで PostgreSQL に記録。シグナル評価・ペーパートレード機能を持つデーモン。WASM フロントエンド付き。
- **パス**: `/home/takamiz/stock-db`
- **技術**: Rust / sqlx / axum / Leptos (WASM) / OpenTelemetry (Jaeger)
- **デプロイ**: thales (`stock-db-daemon.service`, port 3000)

#### stock-Spatiotemporal（次世代研究・実験的）
- **概要**: 衛星画像・気象データ等オルタナティブデータ + カオス理論（リャプノフ指数・ハースト指数）+ Bayesian Transformer によるレジーム検知。「Brain（LLM）と Hands（Rust実行）の分離」が設計思想。
- **パス**: `/home/takamiz/repo/stock-Spatiotemporal`
- **状態**: 実装計画書のみ、コミットなし
- **技術**: Rust / sqlx / TimescaleDB / PostGIS / Polars / ndarray

### Family Asset Dashboard
- **概要**: 家庭内資産管理ダッシュボード
- **技術**: 未定

### 自動日記生成アプリ
- **概要**: AIを活用した日記の自動生成
- **技術**: Rust / Wasm / Cloudflare Workers

---

## 技術スタック

- **Languages**: Rust, Python, Ruby (Rails), PHP
- **Infrastructure**: Docker, Cloudflare Workers, Raspberry Pi
- **Experience**: サーバーサイドエンジニア (15年超)
