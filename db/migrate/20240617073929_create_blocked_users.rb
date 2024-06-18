class CreateBlockedUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :blocked_users do |t|
      t.integer :blocking_user
      t.integer :blocked_user

      t.timestamps
    end
  end
end
