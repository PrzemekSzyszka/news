require 'active_record'

class User < ActiveRecord::Base
  validates :username, :password, presence: true

  has_many :votes
end
