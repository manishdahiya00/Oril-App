class CreateVerificationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :verification_requests do |t|
      t.string :user_id
      t.string :social_type
      t.string :social_id
      t.string :status,default: "Verification Request"

      t.timestamps
    end
  end
end
