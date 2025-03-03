module SlaEventsHelper
    def work_orders
        if @project
            @project.issues.select { |issue| issue.tracker_id == Setting.plugin_redmine_gercont["demand"].to_i }.map { |issue| [issue.subject, issue.id] }
        end
    end
end
