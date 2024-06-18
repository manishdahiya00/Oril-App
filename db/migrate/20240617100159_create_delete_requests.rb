class CreateDeleteRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :delete_requests do |t|
      t.integer :user_id
      t.string :reason

      t.timestamps
    end
  end
end
