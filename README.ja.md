<div align="center">

<img src="docs/readme-app-icon.png" width="220" alt="killeverybody アプリアイコン" />

# killeverybody

### Mac で実行中のアプリとその子プロセスをまとめて整理します。

[한국어](README.md) | [English](README.en.md) | **日本語**

このドキュメントは **v3.0.0** に対応しています。

キプラー氏の Windows 用ツール [AllKill](http://kippler.com/allkill/)（*다죽여*）に着想を得て作りました。

</div>

---

## 最初にお読みください

> **注意:** このアプリは対象プロセスに `SIGKILL` を送ります。保存していない作業は失われる場合があります。

**みんな殺す**と**ほどほどに殺す**は、ボタンを押すと追加確認なしですぐ実行されます。これは意図した動作です。最初は DMG に同梱されている `killeverybody-cli` でドライランすることをおすすめします。

```bash
/Volumes/killeverybody/killeverybody-cli --dry-run
```

## 機能

| 機能 | 動作 |
| --- | --- |
| **みんな殺す** | 実行中のアプリとその子プロセスを終了します。固定のシステム保護リストと killeverybody 自身だけを残し、保存した例外は適用しません。 |
| **ほどほどに殺す** | 同じ範囲から、ユーザーが選んだ例外アプリ、メニューバー扱いのアプリ、内蔵プリセット、`LSUIElement` アプリを除外します。 |
| **例外アプリを設定…** | アイコン付きのアプリ一覧を、名前・バンドル ID・パスで検索してチェックできます。フィルターと保存される並べ替えメニューもあります。 |
| **このアプリを強制終了** | 実行中のアプリを右クリックすると、そのアプリと子・ヘルパープロセスだけを追加確認なしで終了します。例外設定は変わりません。 |
| **한국어・English・日本語** | 詳細設定で言語を選ぶと、メインダイアログと設定 UI にすぐ反映されます。 |
| **再起動の抑制** | 対象アプリに一致するサードパーティ製 LaunchAgent を、現在のログインセッションだけ停止します。次回ログイン時には通常どおり読み込まれます。 |
| **自動アップデート** | Sparkle が GitHub Releases を確認し、可能な場合は新しいアップデートを自動でダウンロードしてインストールします。 |

すべて正常に終了できた場合、結果ダイアログを出さずに killeverybody も正常終了します。失敗した項目がある場合だけ結果を表示し、必要に応じて管理者権限での再試行を選べます。

## インストールとアップデート

動作環境は **macOS 13 Ventura 以降**です。

1. [最新リリース](https://github.com/devuterian/killeverybody/releases/latest)から `KillEverybody-macOS.dmg` をダウンロードします。
2. DMG を開き、`killeverybody.app` を **アプリケーション**フォルダに移します。
3. アプリを起動します。

現在の GitHub Actions 版には **Apple Developer ID 署名と公証がありません**。macOS にブロックされた場合は、アプリを一度 **右クリック → 開く** で起動するか、**システム設定 → プライバシーとセキュリティ**から許可してください。

アプリの起動時に Sparkle がバックグラウンドで新しいバージョンを確認します。手動で確認する場合はアプリメニューの **アップデートを確認…**、ブラウザで入手する場合は **最新リリースを開く…** を選びます。アップデート DMG の整合性は Sparkle の EdDSA 署名で確認されます。

## 使い方

1. アプリを起動すると、macOS 標準スタイルの **「みんな殺す？」** ダイアログが開きます。
2. 対象をすべて整理する場合は **みんな殺す**を選びます。
3. 残したいアプリがある場合は、先に **例外アプリを設定…**でチェックしてから **ほどほどに殺す**を選びます。
4. killeverybody だけを閉じる場合は **終了**を選ぶか、`Esc` キーを押します。

### 「ほどほどに殺す」で生き残るアプリ

**例外アプリを設定…**を選ぶと、別の設定ウィンドウが開きます。

- インストール済み・実行中のアプリをアイコン付きで表示します。
- アプリ名、バンドル ID、パスで検索できます。
- **保護中を先に**（既定）、**未保護を先に**、**名前順**で並べ替えられ、最後の選択が保存されます。
- 実行中のアプリを右クリックして **このアプリを強制終了**を選ぶと、そのアプリと子・ヘルパープロセスだけをすぐ終了します。成功時は実行状態だけを更新し、失敗した場合だけ通知します。
- 初回起動時だけ、macOS のログインアプリを初期例外としてチェックします。この一覧の読み取りで管理者パスワードを求めることはありません。
- チェックの変更はすぐ保存されます。
- **詳細**タブでは 한국어・English・日本語を選び、バンドル ID を直接入力したり、メニューバーアプリとして扱うバンドルを追加したりできます。
- 現在の例外・メニューバー設定を JSON で書き出し、あとから読み込めます。

## CLI とドライラン

DMG 内の `killeverybody-cli` は、デフォルトでドライランします。候補を表示するだけで、シグナルは送りません。

```bash
# 控えめに終了する候補
/Volumes/killeverybody/killeverybody-cli --dry-run

# すべて終了する候補
/Volumes/killeverybody/killeverybody-cli --aggressive --dry-run

# JSON で表示
/Volumes/killeverybody/killeverybody-cli --dry-run --json

# アプリから書き出したポリシー JSON を適用
/Volumes/killeverybody/killeverybody-cli --policy ./killeverybody-policy.json --dry-run
```

CLI はアプリに保存された設定を自動では読みません。同じ例外を使うには、アプリからポリシー JSON を書き出して `--policy` で指定してください。実際の終了は `--execute` と `--yes` を両方指定した場合だけ動作します。

## 対象範囲と制限

- 対象は、**現在のユーザーが実行しているアプリとその子プロセス**です。UID が同じという理由だけで、すべてのシェルやバックグラウンドプロセスを終了することはありません。
- macOS の主要プロセスと killeverybody 自身は、固定の保護リストで除外します。
- アプリのヘルパーは、最も外側のアプリバンドルにまとめて例外を判断します。
- 再起動の抑制は、`~/Library/LaunchAgents` と `/Library/LaunchAgents` にある一致したサードパーティ製項目を、現在の GUI セッションだけ停止します。plist やログイン項目は変更しません。
- メニューバーアプリの判定には公開 API のヒューリスティックを使うため、完璧ではありません。
- Finder など macOS が直接管理するアプリは再起動する場合があります。
- データの保護やシステムの安定動作は保証しません。大切な作業は先に保存してください。

## ビルド

Xcode で `KillEverybodyApp/KillEverybodyApp.xcodeproj` を開き、**KillEverybodyApp** スキームを実行します。コマンドラインでビルドする場合は次のとおりです。

```bash
cd KillEverybodyApp
xcodebuild -scheme KillEverybodyApp -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

CLI は **KillEverybodyCLI** スキームでビルドできます。詳しくは [`docs/build.md`](docs/build.md)をご覧ください。

## ソースとコントリビューション

- リポジトリ: [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)
- コントリビューションと Sparkle 設定: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- 手動スモークテスト: [`docs/smoke-test.md`](docs/smoke-test.md)
- 動作仕様: [`SPEC.md`](SPEC.md)
- 不具合と質問: [Issues](https://github.com/devuterian/killeverybody/issues)

## ライセンス

[MIT License](LICENSE)です。危険性のあるツールなので、免責事項も確認してください。

---

<div align="center">

リポジトリの運用とドキュメント構成は [LPFchan/repo-template](https://github.com/LPFchan/repo-template) を参考にしています。<br>
テンプレートを公開してくださり、ありがとうございます。

</div>
