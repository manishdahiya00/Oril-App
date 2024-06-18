class Reel < ApplicationRecord
  has_one_attached :video
  belongs_to :user, foreign_key: "creater_id"
  has_many :comments
  belongs_to :music, optional: true
end
