class AddUniqueIndexToMultipleTables < ActiveRecord::Migration[7.2]
  def change
  add_index :issue_statuses, :name, unique: true
  add_index :projects, :name, unique: true
  add_index :trackers, :name, unique: true
  add_index :roles, :name, unique: true
  add_index :custom_fields, :name, unique: true
  add_index :custom_field_enumerations, :name, unique: true
  add_index :users, [:firstname, :lastname], unique: true
  add_index :queries, :name, unique: true
  end
end
