require "test_helper"

class FactoryBotExperimentTest < ActiveSupport::TestCase
  test "data starts empty and create inserts on demand" do
    assert_equal 0, User.count
    assert_difference("User.count", 1) { create(:user) }
  end

  test "build does not save or run the creation callback" do
    assert_no_difference("User.count") do
      user = build(:user, email: " Alice@EXAMPLE.COM ")
      assert_not user.persisted?
      assert_nil user.id
      assert_equal " Alice@EXAMPLE.COM ", user.email
    end
  end

  test "create validates and runs the creation callback" do
    user = create(:user, email: " Alice@EXAMPLE.COM ")
    assert user.persisted?
    assert_equal "alice@example.com", user.reload.email
    assert_raises(ActiveRecord::RecordInvalid) { create(:user, name: nil) }
  end

  test "build_stubbed looks persisted but has no database row" do
    assert_no_difference("User.count") do
      user = build_stubbed(:user)
      assert user.persisted?
      assert_not_nil user.id
      assert_not User.exists?(user.id)
      assert_raises(RuntimeError) { user.reload }
    end
  end

  test "traits and overrides express variations" do
    user = build(:user, :admin, name: "Bob")
    assert user.admin?
    assert_equal "Bob", user.name
  end

  test "sequences generate distinct email addresses" do
    first, second = create_list(:user, 2)
    assert_not_equal first.email, second.email
  end
end
