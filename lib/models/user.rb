require 'active_record'

class User < ActiveRecord::Base
  validates :username, :password_hash, presence: true
  validates :username, uniqueness: true
  has_many :votes
  has_many :stories

  before_create :encrypt_password

  include BCrypt

  def encrypt_password
    self.password_hash = Password.create(self.password_hash)
  end

  def password
    Password.new(password_hash)
  end
end
