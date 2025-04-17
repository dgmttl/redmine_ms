if self.tracker_id == @demand && self.status_id == @request_approval
    versions = Version.find(@issue.custom_field_value(@field_for_requested_versions))
    if versions.any? { |version| version.fixed_issues.blank? }

        raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_missing_fixed_issues)
    end
end