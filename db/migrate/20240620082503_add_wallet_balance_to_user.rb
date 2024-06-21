class AddWalletBalanceToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :wallet_balance, :integer,default: 0
    add_column :users, :check_in_balance, :integer,default: 0
    add_column :users, :received_from_fans, :integer,default: 0
    add_column :users, :video_upload_coins, :integer,default: 0
    add_column :users, :total_spending, :integer,default: 0
    add_column :users, :last_check_in, :datetime
  end
end
