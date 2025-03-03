class CreateWorkOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_work_orders do |t|
      # t.integer :contract_id
      t.integer :issue_id

      t.timestamps
    end
  end
end
