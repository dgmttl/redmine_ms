if self.issue_to.present?
  if self.issue_to.tracker_id != @pbi_tracker_id || self.issue_to.sprint != self.issue_to.sprint
    raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_relation_must_be_open_story)
  end
end
