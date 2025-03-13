class WorkOrderProfessional < ApplicationRecord
    self.table_name = 'contract_work_order_professionals'

    belongs_to :work_order
    # has_one :issue, through: :work_order
    # has_one :contract, through: :issue
    # has_one :project, through: :issue
end
