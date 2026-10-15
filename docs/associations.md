# 関連モデルの準備を観察する

共通モデルは `User has_many :posts` / `Post belongs_to :user` です。
今回の目的は、呼び出しの回数と、実際に準備されるDB行数の違いを確認することです。

## 1. FactoryBotの関連定義

`test/factories/posts.rb` の `association :user` は、Postのuserをuser factoryで用意する指定です。
モデルの `belongs_to :user` 自体がUserを自動生成するわけではありません。

```ruby
factory :post do
  title { "First post" }
  association :user
end
```

## 2. コンソールで件数の差を確認する

```sh
bin/rails console -e test --sandbox
```

```ruby
FactoryBot.reload
before = [User.count, Post.count]
post = FactoryBot.create(:post)
after = [User.count, Post.count]
after.zip(before).map { |a, b| a - b }
# => [1, 1]（User、Postの順）

post.reload.user_id
post.user.reload.id
```

続けて、関連先を指定しない2件と、関連先を共有する2件を比べます。

```ruby
before = [User.count, Post.count]
posts = FactoryBot.create_list(:post, 2)
[User.count, Post.count].zip(before).map { |a, b| a - b }
# => [2, 2]
posts.map { |p| p.reload.user_id }
# 異なる2つのUser ID

user = posts.first.user
before = [User.count, Post.count]
shared_posts = FactoryBot.create_list(:post, 2, user: user)
[User.count, Post.count].zip(before).map { |a, b| a - b }
# => [0, 2]
shared_posts.map { |p| p.reload.user_id }
# 同じUser ID
exit
```

sandboxなので、このコンソールで追加した行は終了時にロールバックされます。
通常のcreateで関連Userも保存するので、そのUserの検証・作成時コールバックも実行対象になります。

公式資料: [Association build strategies](https://thoughtbot.github.io/factory_bot/associations/build-strategies.html)

## 実験テストの実行

```sh
bin/rails test test/models/association_experiment_test.rb --verbose
```

テストは期待する件数や関連をassertしているので、成功はその挙動を確認できたことを意味します。
自分で停止させたい場合は、このテストファイル内の観察したい行の直前に一時的に `binding.break` を置きます。
`User.count`、`Post.count` を確認し、`next` で進めて再確認してください。
終了は `continue`、実験後は `binding.break` を削除します。

FactoryBotも既存Userを渡せば再利用できます。Fixturesも準備時にはDBへの書き込みが必要です。
関連が深くなると生成処理が増える可能性がありますが、この実験は実行速度の比較ではありません。
