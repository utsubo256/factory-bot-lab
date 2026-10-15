require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "name and email are required" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:email], "can't be blank"
  end

  test "creating a user normalizes the email" do
    user = User.create!(name: "Alice", email: " Alice@EXAMPLE.COM ")
    assert_equal "alice@example.com", user.reload.email
  end
end
