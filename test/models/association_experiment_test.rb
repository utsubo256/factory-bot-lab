require "test_helper"

class AssociationExperimentTest < ActiveSupport::TestCase
  test "creating one post also creates its user" do
    assert_equal [0, 0], [User.count, Post.count]

    assert_difference(["User.count", "Post.count"], 1) do
      post = create(:post)
      assert_equal User.last.id, post.reload.user_id
      assert post.user.reload.persisted?
    end
  end

  test "default association creates a new user for each post" do
    assert_difference(["User.count", "Post.count"], 2) do
      first, second = create_list(:post, 2)
      assert_not_equal first.reload.user_id, second.reload.user_id
    end
  end

  test "passing an existing user shares it without creating another" do
    user = create(:user)

    assert_no_difference("User.count") do
      assert_difference("Post.count", 2) do
        posts = create_list(:post, 2, user: user)
        assert_equal [user.id], posts.map { |post| post.reload.user_id }.uniq
      end
    end
  end
end
