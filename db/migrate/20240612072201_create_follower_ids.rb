class CreateFollowerIds < ActiveRecord::Migration[7.1]
  def change
    create_table :follows do |t|
      t.string :following_id
      t.string :follower_id

      t.timestamps
    end
  end
end
