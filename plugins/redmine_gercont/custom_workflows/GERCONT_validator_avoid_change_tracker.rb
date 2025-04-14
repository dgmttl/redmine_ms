if !new_record? && tracker_changed?
    raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_can_not_be_changed)
end

