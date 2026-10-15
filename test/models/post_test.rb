require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "a post requires a title and an author" do
    post = Post.new
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
    assert_includes post.errors[:user], "must exist"
  end

  test "a saved post belongs to its author" do
    user = User.create!(name: "Writer", email: "writer@example.com")
    post = Post.create!(title: "First post", user: user)

    assert_equal user, post.reload.user
    assert_includes user.posts.reload, post
  end
end
