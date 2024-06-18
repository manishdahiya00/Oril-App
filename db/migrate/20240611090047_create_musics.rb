class CreateMusics < ActiveRecord::Migration[7.1]
  def change
    create_table :musics do |t|
      t.string :title
      t.string :music_url
      t.string :image_url
      t.string :singer

      t.timestamps
    end
  end
end
