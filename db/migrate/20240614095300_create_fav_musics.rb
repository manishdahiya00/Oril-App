class CreateFavMusics < ActiveRecord::Migration[7.1]
  def change
    create_table :fav_musics do |t|
      t.integer :user_id
      t.integer :music_id

      t.timestamps
    end
  end
end
