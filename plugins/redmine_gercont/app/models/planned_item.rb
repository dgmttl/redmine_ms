class PlannedItem < ApplicationRecord
    self.table_name = 'contract_planned_items'

    belongs_to :work_plan
    belongs_to :item, class_name: 'Item', foreign_key: 'item_id'

end
