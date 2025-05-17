class WorkOrder < ApplicationRecord
    self.table_name = 'contract_work_orders'

    attribute :static_data, :json, default: {}
   
    belongs_to :issue
    # has_one :contract, through: :issue
    has_one :project, through: :issue
    has_one :work_plan, through: :issue
    has_many :sla_events    
    has_many :work_order_professionals


    STATUSES = [
                'new', 
                'attending',
                'paused', 
                'delivered',
                'accepted',
                'rejected',
                'waiting_payment', 
                'closed',
                'cancelled'
                ].freeze

    def self.status_options
        STATUSES.map { |status| [I18n.t("statuses.work_order.#{status}"), status] }
    end

    def contract
        return nil if issue.nil?
        
        issue.work_plan.work_plan_items.first.item.contract
    end

    def sprints
        issue.children.map(&:sprint)
    end

    def static_data
        JSON.parse(super.to_json, symbolize_names: true) if super.present?
    end

    def fill_static_data
      work_plan = self.work_plan.load_baseline
      start_by = Holiday.next_work_day + work_plan.days_allocation
      finish_by = start_by + 1

      {
        identification: {
          contract_number: contract.name,
          issue_date: Date.today,
          object: contract.object,
          contractor: contract.contractor,
          cnpj: contract.cnpj,
          agent: contract.agent.user.name,
          terms_start: contract.terms_start,
          terms_end: contract.terms_end
        },
        requester_area: {
          unity: project.custom_field_value(CustomField.requester_unity.id),
          requester: issue.author.name,
          requester_email: issue.author.mail
        },
        objective: issue.description,
        work_order_items: work_plan.work_plan_items,
        nominal_value: work_plan.total,
        productivity_target: l(:text_productivity_target),
        days_allocation: { 
          start_date: Holiday.next_work_day,
          end_date: Holiday.next_work_day + work_plan.days_allocation,
          calendar_days: work_plan.days_allocation
        },
        schedule: self.work_plan.sprints_objects.map do |sprint|
          finish_by = start_by + Holiday.calendar_days(Scrum::Setting.default_sprint_days.to_i, start_by) 

          sprint_data = {
            id: sprint[:index],
            version: sprint[:versions].map(&:name).join(', '),
            stories: sprint[:pbis].map(&:subject).join(', '),
            start_by: start_by,
            finish_by: finish_by
          }

          start_by = Holiday.next_work_day_after(finish_by)
          sprint_data
        end,
        deadline: finish_by,
        non_funcional_requirements: self.issue.checklists,
        contract_manager: User.current.name
      }
    end

    def self.sla_events
      self.sla_events.where.not(status: 'closed')
    end
end
