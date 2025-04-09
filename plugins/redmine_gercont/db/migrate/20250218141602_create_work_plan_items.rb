class CreateWorkPlanItems < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_work_plan_items do |t|
      t.integer :work_plan_id, null: false
      t.integer :item_id, null: false
      
      t.integer :quantity
      t.decimal :percentage, precision: 5, scale:2
      t.text :rationale
      t.text :sprints, null: false

      t.timestamps
    end
  end
end
