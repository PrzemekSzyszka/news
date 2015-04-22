class Vote < ActiveRecord::Base
  validates :user, :story, :value, presence: true
  validates :user, uniqueness: { scope: :story }

  belongs_to :user
  belongs_to :story
end
