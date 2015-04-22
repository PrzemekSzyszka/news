require 'active_record'

class Story < ActiveRecord::Base
  validates :title, :url, presence: true

  has_many :votes
end
