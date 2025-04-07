class CreateWorkOrderProfessionals < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_work_order_professionals do |t|
      t.integer :work_order_id
      t.date  :start_date
      t.date  :end_date

      t.timestamps
    end
  end
end
