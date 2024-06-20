class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :user_id
      t.string :amount
      t.string :payment_id
      t.string :order_id
      t.string :receipt

      t.timestamps
    end
  end
end
