class Item < ActiveRecord::Base
    self.table_name = 'contract_items'

    belongs_to :contract
    has_many :planned_items
    has_many :plans, through: :planned_items

end
