# factory-bot-lab

FactoryBot のテストデータ準備を実験するRailsアプリです。
比較対象は隣の `fixtures-lab` です。共通のUserモデルを使います。

## 環境

- Ruby 4.0.7（`.ruby-version`）
- Rails 8.1.4（解決済みの依存関係は `Gemfile.lock`）
- SQLite / Minitest 5
- factory_bot_rails 6.5.1 / factory_bot 6.6.0

## セットアップとテスト

リポジトリのディレクトリ内で実行します。

```sh
mise install ruby@4.0.7
ruby -v
bin/setup --skip-server
bin/rails test
```

実験だけを実行する場合:

```sh
bin/rails test test/models/factory_bot_experiment_test.rb --verbose
```

開発サーバーを起動する場合:

```sh
bin/rails server -b 127.0.0.1 -p 3000
```

`http://127.0.0.1:3000/up` で起動を確認できます。停止はCtrl-Cです。
テストとコンソールで観察するためのアプリで、UserのCRUD画面はありません。
テストデータは開発DBと別のテストDBに入ります。

## FactoryBotで観察すること

定義は `test/factories/users.rb`、実験は `test/models/factory_bot_experiment_test.rb` にあります。

- `build(:user)` は未保存のインスタンスを作ります。このfactoryではDB行が増えません。
- `create(:user)` は必要な時点で保存し、モデルのバリデーションと `before_create` を実行します。
- `build_stubbed(:user)` は保存済みのように振る舞いますが、DB行は作りません。`reload` はエラーになります。
- `:admin` trait、属性の上書き、emailのsequenceでデータのバリエーションを作れます。
- 各テストは空のテストDBから始まり、必要なデータを明示的に作ります。

例えば `create(:user, name: nil)` を `build(:user, name: nil)` に変えて、例外の発生タイミングがどう変わるか予想してから試してください。

`build` が関連モデルまで保存しないかどうかは、associationの定義やstrategyにも依存します。この実験のUserには関連がありません。

公式資料: [FactoryBot build strategies](https://thoughtbot.github.io/factory_bot/using-factories/build-strategies.html)

## 共通モデル

Userはnameとemailを必須とし、`before_create` でemailの空白除去・小文字化を行います。
adminのDBデフォルト値はfalseです。共通のモデルテストは `test/models/user_test.rb` にあります。

| 観察対象 | FactoryBot | Fixtures |
| --- | --- | --- |
| データの定義 | Rubyのfactory | YAMLのラベル付きデータ |
| DBに入るタイミング | `create` を呼ぶとき | テスト準備時に読み込み |
| 保存せず使う | `build` / `build_stubbed` | 読み込まれたデータは保存済み |
| モデルの検証・作成callback | 通常の `create` で実行 | 挿入時には実行しない |
| バリエーション | trait、上書き、sequence | ラベルを追加、または取得後に変更 |

この比較は同じRails/Minitestの条件で行います。速度の優劣を測るベンチマークではありません。

## アプリ生成コマンド

親ディレクトリで実行したコマンドです。初回コミットの本文にも記録しています。

```sh
rails _8.1.4_ new factory-bot-lab --minimal --database=sqlite3 --skip-docker --skip-kamal --skip-ci --skip-rubocop --skip-brakeman --skip-bundler-audit --skip-bundle --no-rc
cd factory-bot-lab
bundle install
bin/rails db:prepare
bin/rails test
```

`--minimal` でテストに不要な機能を省き、Active RecordとMinitestを残しています。
追加したファイル・設定・依存gemはGit履歴を参照してください。

## コミットの方針

環境生成、テスト支援設定、共通モデル、実験、ドキュメントを別のコミットにしています。
共通モデルはテストの失敗（Red）を確認してから実装し、成功（Green）を確認してコミットしました。
各コミットは、目的が一つで、テストが通る状態を基本としています。
