class WorkOrderProfessional < ApplicationRecord
    self.table_name = 'contract_work_order_professionals'

    belongs_to :work_order
end
