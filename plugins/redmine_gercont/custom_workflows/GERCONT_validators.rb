if @issue.contracts_any? 
    
    #Avoid change tracker
    if !new_record? && @issue.tracker_changed?
        raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_can_not_be_changed)
    end
    
    if @issue.parent.present?
        
        # Avoid change story and tasks
        if (@issue.is_pbi? || @issue.is_task?)
            permited = [
                IssueStatus.new_status,
                IssueStatus.request_approval,
                IssueStatus.plan_drafting, 
                IssueStatus.service_in_progress, 
                IssueStatus.request_work_plan_adjustment
            ]
            unless permited.include?(@issue.parent.status)
                raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_can_t_be_changed)
            end
        end

        # Avoid create subtask
        if @issue.story? && !@issue.parent.demand?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_story_can_not_be_created)
        end

        if @issue.task? && !@issue.parent.demand?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_task_can_not_be_created)
        end

        if @issue.story?
            parent_versions_ids = parent.custom_field_value(CustomField.requested_versions.id).map(&:to_i)
            if @issue.fixed_version.nil? || !parent_versions_ids.include?(@issue.fixed_version.id)
                parent_versions_names = Version.find(parent_versions_ids).map(&:name).join(', ')
                raise RedmineCustomWorkflows::Errors::WorkflowError, 
                    l(:warning_cw_issue_story_can_not_be_created_missing_fixed_version, versions: parent_versions_names)
            end
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

    if @issue.status == IssueStatus.request_approval 
       
       # Avoid missing non funcional requisites
        if @issue.checklists.blank?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_missing_non_functional_requisites)
        end

        # Avoid versions missing issues
        selected_versions = @issue.custom_field_value(CustomField.requested_versions.id)

        if @issue.tracker == Tracker.demand
            versions = Version.find(selected_versions)
            if versions.any? { |version| version.fixed_issues.blank? }
                raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_tracker_missing_fixed_issues)
            end
        end
    end

    # Avoid request work plan approval
    if @issue.status == IssueStatus.request_work_plan_approval
        if @issue.work_plan.sprints.blank?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_request_work_approval_missing_sprints)
        elsif @issue.work_plan.work_plan_items.blank?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_request_work_approval_missing_items)
        elsif @issue.work_plan.sprints.present?
            if missing_any_sprint?
                raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_request_work_approval_missing_items_in_all_sprints)
            end
        end
    end

    
    if @issue.status == IssueStatus.generate_work_order

        # Avoid generate work order missing fields
        if @issue.project.custom_field_value(CustomField.requester_unity.id).blank?
            raise RedmineCustomWorkflows::Errors::WorkflowError, l(:warning_cw_issue_demand_can_not_generate_work_order_missing_requester_unity)
        end
    end

end
