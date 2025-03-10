class CreatePlannedItems < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_planned_items do |t|
      t.references :work_plan, null: false, foreign_key: { to_table: :contract_work_plans }
      t.references :item, null: false, foreign_key: { to_table: :contract_items }
      
      t.integer :quantity
      t.decimal :percentage, precision: 5, scale:2
      t.text :sprints

      t.timestamps
    end
  end
end
