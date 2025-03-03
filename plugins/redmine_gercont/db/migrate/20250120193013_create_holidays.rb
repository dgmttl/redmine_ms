class CreateHolidays < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_holidays do |t|
      t.date :date
      t.text :description
      t.integer :contract_id
    end
  end
end
