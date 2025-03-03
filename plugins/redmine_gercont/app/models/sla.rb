class Sla < ActiveRecord::Base
    self.table_name = 'contract_slas'
    
    belongs_to :contract
    has_many :sla_events
    belongs_to :custom_workflow, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
    validates :acronym, presence: true, uniqueness: true
    validates :frequency, presence: true
    validates :target, presence: true
end
