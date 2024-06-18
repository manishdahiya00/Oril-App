class CreateReels < ActiveRecord::Migration[7.1]
  def change
    create_table :reels do |t|
      t.integer :music_id
      t.string :description
      t.string :hastags
      t.boolean :allow_comments
      t.integer :like_count,default: 0
      t.integer :view_count,default: 0
      t.integer :report_count,default: 0
      t.integer :creater_id
      t.boolean :isReported,default: false

      t.timestamps
    end
  end
end
