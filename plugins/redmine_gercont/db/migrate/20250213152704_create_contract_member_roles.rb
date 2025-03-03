class CreateContractMemberRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_member_roles do |t|
      t.references :contract_member, null: false, foreign_key: { to_table: :contract_members }
      t.references :role, null: false, foreign_key: { to_table: :roles }
      
      t.timestamps
    end
  end
end
