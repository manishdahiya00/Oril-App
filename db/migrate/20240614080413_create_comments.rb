class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :reel_id
      t.text :content

      t.timestamps
    end
  end
end
