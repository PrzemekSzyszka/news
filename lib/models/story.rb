require 'active_record'

class Story < ActiveRecord::Base
  validates :title, :url, presence: true

  has_many :votes

  def score
    votes.sum(:value)
  end

  def as_json(options)
    super.merge({ score: self.score })
  end
end
