class Assessment < ActiveRecord::Base
    self.table_name = 'contract_assessments'
    
    belongs_to :work_order_professional    
    has_one :work_order, through: :work_order_professional
    has_one :sla_event, through: :work_order	
    has_one :issue, through: :work_order
    has_one :project, through: :issue


    validates :attendance, presence: true
    validates :technical_expertise, presence: true
    validates :conduct, presence: true
    validates :sla_event_id, presence: true
    validates :user_id, presence: true
   
    ANSWERS = {
        0 => 'terrible',
        1 => 'bad',
        2 => 'fair',
        3 => 'good', 
        4 => 'excellent'
    }.freeze

    def self.answers_options
        ANSWERS.map { |key, value| [I18n.t("answers.#{value}"), key] }
    end

    def measured_value 
      valores = [attendance, technical_expertise, conduct].compact 
      valores.empty? ? 0 : valores.sum 
    end
   
    def self.human_attribute_name(attribute_key_name, *args)
        attr_name = attribute_key_name.to_s
        if attr_name == "sla_event_id"
            attr_name = "sla_event_work_order"
        end
        if attr_name == "user_id"
            attr_name = "user_assesse"
        end
        super(attr_name, *args)
    end
end 