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
        work_plan = work_plan.load_baseline
       { 
            identification: { 
                contract_number: contract.name,
                issue_date: Holiday.next_work_day,
                object: contract.object,
                contractor: contract.contractor,
                cnpj: contract.cnpj,
                agent: contract.agent.user.name,
                terms_start: contract.terms_start,
                terms_end: contract.terms_end
            },

            requester_area: {
                unity: project.custom_field_value(Setting.plugin_redmine_gercont['field_for_requester_unity'].to_i),
                requester: issue.author.name,
                requester_email: issue.author.mail
            },
            
            objective: issue.description,
            work_order_items: work_plan.work_plan_items,            
            productivity_target: l(:text_productivity_target),
            days_allocation: { 
                start_date: Holiday.next_work_day,
                end_date: Holiday.next_work_day + work_plan.days_allocation,
                calendar_days: work_plan.days_allocation
            },
            schedule: sprints.each do |sprint, version|
                {
                  version: version,
                  start_date: sprints.map { |sprint| sprint.start_date }.min, 
                  end_date: sprints.map { |sprint| sprint.end_date }.max, 
                  sprints: sprints.map do |sprint|
                    {
                      id: sprint.id,
                      start_date: sprint.start_date,
                      end_date: sprint.end_date,
                      stories: sprint.pbis.map(&:subject).join(', ')
                    }
                  end
                }
            end,
            non_funcional_requirements: issue.custom_field_value(Setting.plugin_redmine_gercont['field_for_non_funcional_requirements'].to_i),
            }
    end


end
