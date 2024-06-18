class User < ApplicationRecord
  has_many :follows, foreign_key: "follower_id"
  has_many :following, through: :follows, source: :following
  has_many :inverse_follows, class_name: "Follow", foreign_key: "following_id"
  has_many :followers, through: :inverse_follows, source: :follower
  has_one_attached :profileImage
  has_many :likes
  has_many :fav_musics
  has_many :reels, foreign_key: "creater_id"
  has_many :blocked_users, foreign_key: "blocking_user"
  has_one :delete_request

  scope :with_follower_count, -> {
    left_joins(:inverse_follows)
    .select('users.*, COUNT(follows.id) AS follower_count')
    .group('users.id')
  }

end
