<div align="center">
  <img src="docs/readme-app-icon.png" width="256" height="256" alt="killeverybody アプリアイコン" />
</div>

<div align="center">

# killeverybody <br>

[한국어](README.md) | [English](README.en.md) | [日本語](README.ja.md)

macOS 上のプロセスを **SIGKILL** で終了させるユーティリティです。システムに必須のものは除外し、**ほぼ全部終わらせる**か**いつも通りフィルタしたうえで終わらせる**かを選べます。

着想の一部は、キプラー氏の Windows 向け **다죽여**（AllKill）です。[http://kippler.com/allkill/](http://kippler.com/allkill/)

</div>

---

## インストール

1. **[Releases](https://github.com/devuterian/killeverybody/releases)** から最新の DMG（`KillEverybody-macOS.dmg`）を入手します。
2. DMG を開き、**killeverybody.app** を **アプリケーション** フォルダに入れます。
3. （任意）同じ DMG 内の **killeverybody-cli** はターミナル用です（既定 `--dry-run` は候補表示のみ）。詳しくは [`docs/build.md`](docs/build.md)。
4. アプリを起動します。

**セキュリティ:** CI でビルドしており、**開発者署名・公証がない**場合があります。ブロックされたら **右クリック → 開く** で一度開くか、**システム設定 → プライバシーとセキュリティ** で許可してください。

**アップデート:** メニュー **killeverybody → アップデートを確認…**（Sparkle）。手動なら **最新リリースを開く…** から Releases へ。

---

## 使い方

1. ウィンドウに **一括終了の確認** が表示されます（日本語版では文言がローカライズされます）。
2. **全て終了（強）** — 実行中のアプリとその子プロセスを終了します。保存した例外は **適用しません**。
3. **控えめに終了** — 同じ範囲から、例外アプリ・メニューバーアプリ・LSUIElement アプリを除いて終了します。
4. **例外アプリ…** では、アイコン付きのアプリ一覧を検索してチェックできます。初回起動時だけ macOS のログイン項目を既定でチェックし、その後の変更はすぐ保存します。
5. 終了ボタンを押すと追加確認なしで実行します。成功時は killeverybody も終了し、失敗時だけ結果を表示します。
6. **終了** はアプリだけ閉じます。

一致する LaunchAgent によって再起動されるサードパーティ製アプリは、**現在のログインセッションだけ**エージェントを停止します。plist は変更しないため、次回ログイン時には通常どおり起動できます。

---

## できないこと

- メニューバー常駐アプリの判定は **完璧ではありません**。**控えめに終了** で被害を減らす想定です。
- Finder など macOS が管理するシステムアプリは再起動することがあります。
- システムの安定動作を **保証しません**。

---

## ソース・コントリビューション

リポジトリ: [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)

- ビルド: [`docs/build.md`](docs/build.md)
- コントリビュート・Sparkle 用シークレット: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- スモーク: [`docs/smoke-test.md`](docs/smoke-test.md)
- 仕様メモ: [`SPEC.md`](SPEC.md)

不具合・質問は [Issues](https://github.com/devuterian/killeverybody/issues) へ。

---

## ライセンス

[MIT License](LICENSE)。危険なツールであることと免責条項は本文を確認してください。

---

<div align="center">

リポジトリの運用とドキュメントの枠組みは [LPFchan/repo-template](https://github.com/LPFchan/repo-template) を参考にしています。<br>
テンプレートを公開してくださり、本当にありがとうございます。

</div>
