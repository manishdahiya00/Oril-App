class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :user_id
      t.string :creator_id
      t.string :reel_id
      t.string :content
      t.string :notification_type

      t.timestamps
    end
  end
end
