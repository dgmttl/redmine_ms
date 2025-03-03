class CreatePlans < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_plans do |t|
      t.integer :issue_id
      t.text :baseline

      t.timestamps
    end
  end
end
