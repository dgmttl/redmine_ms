class CreateRules < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_rules do |t|
      t.string :action
      t.integer :contract_id
      t.integer :tracker_id
      t.integer :custom_workflow_id
    end
  end
end
