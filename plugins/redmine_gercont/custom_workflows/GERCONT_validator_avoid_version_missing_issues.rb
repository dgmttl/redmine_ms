selected_versions = @issue.custom_field_value(@field_for_requested_versions)

if @issue.tracker_id == @demand && requested_versions_changed? && selected_versions != ['']
    versions = Version.find(selected_versions)
    if versions.any? { |version| version.fixed_issues.blank? }
        raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_missing_fixed_issues)
    end
end