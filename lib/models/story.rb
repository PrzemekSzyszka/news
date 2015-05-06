require 'active_record'

class Story < ActiveRecord::Base
  validates :title, :url, :user_id, presence: true

  belongs_to :user
  has_many :votes

  def score
    votes.sum(:value)
  end

  def as_json(options)
    super(options).merge(score: self.score)
  end
end
