class CreateSlas < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_slas do |t|
      t.text :name
      t.text :description
      t.text :acronym
      t.text :frequency
      t.boolean :assessments
      t.integer :target
      t.integer :contract_id
      t.integer :custom_workflow_id
    end
  end
end
