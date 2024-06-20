class AddWalletBalanceToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :wallet_balance, :integer,default: 0
  end
end
