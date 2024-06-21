class CreatePayouts < ActiveRecord::Migration[7.1]
  def change
    create_table :payouts do |t|
      t.string :payout_name
      t.string :payout_img_url
      t.string :payout_amount

      t.timestamps
    end
  end
end
