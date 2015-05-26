class Board < ActiveRecord::Base
  validates :name, presence: true

  has_many :stories
end
