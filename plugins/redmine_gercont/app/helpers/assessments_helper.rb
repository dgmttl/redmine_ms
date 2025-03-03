module AssessmentsHelper
    def event_options
        @project.sla_events.map do |event|
          [event.issue.subject, event.id]
        end
    end

    def work_order_options
        @project.sla_events.includes(:issue).map do |event|
          [event.issue.subject, event.id]
        end
    end

    def assesse_options
        @project.principals_by_role.select { |role, principals| roles_for_assessment.include?(role.id) }
                                   .flat_map { |_role, principals| principals.map { |principal| [principal.name, principal.id] } }
    end

    def roles_for_assessment
        Setting.plugin_redmine_gercont["roles_for_assessment"].map(&:to_i)
    end
end
