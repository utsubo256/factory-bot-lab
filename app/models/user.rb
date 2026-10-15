class User < ApplicationRecord
  has_many :posts, inverse_of: :user

  validates :name, :email, presence: true

  before_create :normalize_email

  private

  def normalize_email
    self.email = email.strip.downcase
  end
end
