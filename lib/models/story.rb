require 'active_record'

class Story < ActiveRecord::Base
  validates :title, :url, :user_id, presence: true

  belongs_to :user
  has_many :votes

  scope :popular, -> { joins("LEFT JOIN votes on stories.id = votes.story_id").group("stories.id")
                      .order(["coalesce(sum(value), 0) desc", :id]).limit(10) }
  scope :recent,  -> { order(:updated_at).limit(10) }

  def score
    votes.sum(:value)
  end

  def as_json(options)
    super(options).merge(score: self.score)
  end
end
