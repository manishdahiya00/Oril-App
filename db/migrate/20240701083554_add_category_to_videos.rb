class AddCategoryToVideos < ActiveRecord::Migration[7.1]
  def change
    add_column :reels, :category, :string, default: "trending"
  end
end
