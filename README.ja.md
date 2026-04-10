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
2. **全て終了（強）** — ログインユーザーのプロセスのうち、**組み込みのシステム用 denylist 以外**を終了します。メニューバー用の除外・設定の例外・LSUIElement 相当のスキップは **使いません**。
3. **控えめに終了** — denylist に加え、**設定の例外・メニューバー扱いバンドル・LSUIElement のヒューリスティック・プリセット**など、従来どおりの保護をかけたうえで終了します。
4. 実行前に **件数の確認** が出ます。未保存の作業は失われることがあります。
5. **終了** はアプリだけ閉じます。

**設定** はメニュー **killeverybody → 設定…**（⌘,）から。例外バンドル ID、メニューバー扱いバンドル、ポリシー JSON の書き出し／読み込みがあります。

---

## できないこと

- メニューバー常駐アプリの判定は **完璧ではありません**。**控えめに終了** で被害を減らす想定です。
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
