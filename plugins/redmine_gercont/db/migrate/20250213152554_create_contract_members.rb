class CreateContractMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_members do |t|
      t.integer :contract_id, null: false
      t.integer :user_id, null: false
      t.integer :item_id

      t.timestamps
    end
  end
end
