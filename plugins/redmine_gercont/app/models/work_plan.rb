class WorkPlan < ApplicationRecord
    self.table_name = 'contract_work_plans'

    belongs_to :issue
    has_one :contract, through: :issue
    has_one :project, through: :issue
    has_one :work_order, through: :issue
    has_many :planned_items, dependent: :destroy
    has_many :items, through: :planned_items
end
