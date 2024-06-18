class CreateReportedReels < ActiveRecord::Migration[7.1]
  def change
    create_table :reported_reels do |t|
      t.string :reporting_reason
      t.string :description
      t.string :user_id
      t.string :reel_id

      t.timestamps
    end
  end
end
