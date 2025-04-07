class CreateWorkPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_work_plans do |t|
      t.integer :issue_id
      t.text :status
      t.text :sprints
      t.integer :days_allocation, default: 7
      t.text :baseline
      
      t.timestamps
    end
  end
end
