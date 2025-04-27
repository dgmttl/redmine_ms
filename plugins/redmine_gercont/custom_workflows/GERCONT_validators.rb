if @issue.contracts_any? 
    
    #Avoid change tracker
    if !new_record? && @issue.tracker_changed?
        raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_can_not_be_changed)
    end

    # Avoid create subtask
    if @issue.parent.present?
        if @issue.is_story? && !@issue.parent.is_demand?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_story_can_not_be_created)
        end

        if @issue.is_task? && @issue.parent.is_story?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_task_can_not_be_created)
        end
    end
    
    # Avoid approve demand
    if @issue.status == IssueStatus.approve
        if @issue.active_contracts.count > 1
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_be_approved_many_open_contracts)
        elsif @issue.active_contracts.count == 0
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_be_approved_no_open_contracts)
        end
    end

    # Avoid missing non funcional requisites
    if @issue.status == IssueStatus.request_approval && @issue.checklists.blank?
        raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_missing_non_functional_requisites)
    end

    # Avoid request work plan approval
    if @issue.status == IssueStatus.request_work_plan_approval
        if @issue.work_plan.sprints.blank?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_request_work_approval_missing_sprints)
        elsif @issue.work_plan.items.blank?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_request_work_approval_missing_items)
        end
    end

    # Avoid issue versions custom field missing issues
    if @issue.is_demand? 
        selected_versions = @issue.custom_field_value(CustomField.requested_versions.id)
        if requested_versions_changed? && selected_versions.present?
            versions = Version.find(selected_versions)
            if versions.any? { |version| version.fixed_issues.blank? }
                raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_missing_fixed_issues)
            end
        end
    end
end
