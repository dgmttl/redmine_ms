class CreateSlaEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_sla_events do |t|
      t.text :status
      t.integer :measured_value
      t.integer :sla_id
      t.integer :work_order_id

      t.timestamps
    end
  end
end
