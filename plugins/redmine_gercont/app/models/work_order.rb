class WorkOrder < ApplicationRecord
    self.table_name = 'contract_work_orders'
   
    belongs_to :issue
    has_one :contract, through: :issue
    has_one :project, through: :issue
    has_one :work_plan, through: :issue
    has_many :sla_events    
    has_many :work_order_professionals


end
