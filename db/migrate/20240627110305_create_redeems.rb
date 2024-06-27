class CreateRedeems < ActiveRecord::Migration[7.1]
  def change
    create_table :redeems do |t|
      t.string :number_or_email
      t.string :upi_id
      t.string :user_id
      t.string :coins
      t.string :payout_id
      t.string :status,default: "PENDING"

      t.timestamps
    end
  end
end
