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
    if @issue.status == IssueStatus.approve && @user_roles.include?(Role.contract_manager)
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

    # Avoid change story and tasks
    if @issue.parent.present? && (@issue.is_pbi? || @issue.is_task?)
        permited = [
            IssueStatus.plan_drafting, 
            IssueStatus.service_in_progress, 
            IssueStatus.request_work_plan_adjustment,
            IssueStatus.new_status
        ]
        unless permited.include?(@issue.parent.status)
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_can_t_be_changed)
        end

    end
end
