class CreateContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :contracts do |t|
      t.text :name
      t.text :terms_reference
      t.text :object
      t.date :terms_start
      t.date :terms_end
      t.text :status
      t.text :contractor
      t.text :cnpj

      t.timestamps
    end
  end
end
