class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_items do |t|
      t.text :name
      t.text :description
      t.text :unit_measure
      t.decimal :unit_value, precision: 10, scale: 2
      t.integer :contract_id
      t.string :profile
      t.integer :shared_by, null: false, default: 1
    end
  end
end
