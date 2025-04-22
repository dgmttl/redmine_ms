if @issue.contracts_any? && @issue.tracker_id == @demand && @issue.status_id == @request_approval
    if @issue.checklists.blank?
        raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_missing_non_functional_requisites)
    end
end