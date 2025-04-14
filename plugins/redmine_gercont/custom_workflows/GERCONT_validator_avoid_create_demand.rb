if new_record? && tracker_id == @demand && self.project.versions.empty?
    raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_be_created)
end

