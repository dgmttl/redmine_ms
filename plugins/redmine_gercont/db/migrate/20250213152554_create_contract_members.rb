class CreateContractMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_members do |t|
      t.references :contract, null: false, foreign_key: { to_table: :contracts }
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.text :profile
      t.timestamps
    end
  end
end
