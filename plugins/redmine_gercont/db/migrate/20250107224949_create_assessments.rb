class CreateAssessments < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_assessments do |t|
      t.integer :attendance
      t.integer :technical_expertise
      t.integer :conduct
      t.integer :work_order_professional_id

      t.timestamps
    end
  end
end
