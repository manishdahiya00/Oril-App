class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :transaction_name
      t.string :transaction_amount
      t.string :transaction_coins
      t.string :user_id

      t.timestamps
    end
  end
end
