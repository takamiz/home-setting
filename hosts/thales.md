# Machine Record: thales

## 1. システム環境
- **ホスト名**: `thales`
- **OS**: Debian GNU/Linux 13 (trixie)
- **アーキテクチャ**: `arm64` (Raspberry Pi)
- **カーネル**: Linux 6.12.62+rpt-rpi-v8

## 2. SSH / ネットワーク構成
- **接続先エイリアス**: `thales` (または `rasp`)
- **IPアドレス**: `192.168.0.200`
- **ユーザー**: `takamiz`
- **認証**: 鍵認証 (`~/.ssh/id_ed25519`)
- **Sudo**: `NOPASSWD` 設定済み

## 3. 稼働サービス

### Docker コンテナ
- **wol**: `http://wol.home` (Port 8080) - Wake-on-LAN (legion 起動)
- **lorenzo**: `http://lorenzo.home` (Port 3001)
- **immich**: `http://immich.home` (Port 2283) - 自宅フォトサーバーセット (Up 9 days)
    - `immich_server`
    - `immich_machine_learning`
    - `immich_postgres`
    - `immich_redis`

### Web / システムサービス
- **AdGuard Home**: `http://adguard.home` (Port 3000) - 広告ブロック・DNSリライト
- **Cockpit**: `http://cockpit.home` (Port 9090) - サーバー管理
- **Munin**: `http://munin.home` - リソース監視 (Apache Direct Alias)
- **Apache2**: ポート `80` (HTTP) - リバースプロキシとして稼働
- **Samba**: ファイル共有 (smbd)
- **Tailscale**: メッシュVPN (tailscaled)

## 4. 性能・リソース
- **メモリ**: 3.7GiB (Total)
- **スワップ**: 2.0GiB (Full usage observed)
- **ディスク**: `/dev/sdb2` (235G, 使用量 9%)

## 4. 特記事項
- Raspberry Pi 上で動作するデプロイ・運用用のサーバー。
- Debian trixie (Debian 13) ベースの OS。

---

## DNS / リバースプロキシ詳細設定

### AdGuard Home (DNSリライト)
以下の設定を `AdGuardHome.yaml` または Web UI から適用済み：
```yaml
filtering:
  rewrites:
    - domain: lorenzo.home
      answer: 192.168.0.200
    - domain: immich.home
      answer: 192.168.0.200
    - domain: adguard.home
      answer: 192.168.0.200
    - domain: cockpit.home
      answer: 192.168.0.200
    - domain: munin.home
      answer: 192.168.0.200
    - domain: wol.home
      answer: 192.168.0.200
```

### Apache2 (リバースプロキシ)
`/etc/apache2/sites-available/` に各サービス用の `.conf` ファイルを作成し、`ProxyPass` を設定済み（`wol`, `lorenzo`, `immich`, `adguard`, `cockpit`, `munin-site`）。

## 管理・メンテナンス
- ログイン: `ssh thales`
- 更新: `sudo apt update && sudo apt upgrade`
