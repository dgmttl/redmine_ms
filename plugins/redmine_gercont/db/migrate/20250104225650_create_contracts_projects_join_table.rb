class CreateContractsProjectsJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :contracts, :projects do |t|
    end
  end
end
