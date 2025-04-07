class CreateWorkOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_work_orders do |t|
      t.integer :issue_id
      t.text :static_data
      t.text :status
      t.text :notes
      t.float :discount
      t.float :total

      t.timestamps
    end
  end
end
