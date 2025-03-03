class SlaEvent < ActiveRecord::Base
    self.table_name = 'contract_sla_events'
    
    belongs_to :sla
    belongs_to :work_order    
    has_many :assessments, through: :work_order, dependent: :destroy
    has_one :issue, through: :work_order
    has_one :project, through: :issue


    validates :status, presence: true
    validates :sla_id, presence: true
    validates :work_order_id, presence: true

    STATUSES = ['started', 'completed', 'abstained', 'canceled'].freeze

    def self.status_options
        STATUSES.map { |status| [I18n.t("statuses.sla_events.#{status}"), status] }
    end

    

end
