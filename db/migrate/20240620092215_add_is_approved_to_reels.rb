class AddIsApprovedToReels < ActiveRecord::Migration[7.1]
  def change
    add_column :reels, :is_approved, :boolean,default: false
  end
end
