class CreateContractsTrackersJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :contracts, :trackers do |t|
    end
  end
end
