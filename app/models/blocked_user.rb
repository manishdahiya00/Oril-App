class BlockedUser < ApplicationRecord
  belongs_to :user, foreign_key: "blocking_user"
end
