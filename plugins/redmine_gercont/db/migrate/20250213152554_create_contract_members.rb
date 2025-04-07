class CreateContractMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_members do |t|
      t.references :contract, null: false, foreign_key: { to_table: :contracts }
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :item, foreign_key: { to_table: :contract_items }

      t.timestamps
    end
  end
end
