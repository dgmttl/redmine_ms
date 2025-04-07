module WorkOrdersHelper
    def demand_options
        issues = @project.issues
            .where(tracker_id: Setting.plugin_redmine_gercont['demand_tracker_id'])
            .map { |issue| [issue.to_s, issue.id] }
        busy = WorkOrder.pluck(:issue_id)

        available = issues.reject { |_, issue_id| busy.include?(issue_id) }

        available
    end
end
