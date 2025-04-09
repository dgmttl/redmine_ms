class CreateContractMemberRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_member_roles do |t|
      t.integer :contract_member_id, null: false
      t.integer :role_id, null: false
      
      t.timestamps
    end
  end
end
