class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_items do |t|
      t.text :name
      t.text :description
      t.text :unit_measure
      t.float :unit_value
      t.integer :contract_id
    end
  end
end
