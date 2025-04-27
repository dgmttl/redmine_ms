if @issue.contracts_any?

  if @issue.is_demand?

    if @issue.status == IssueStatus.request_approval
      @new_role_name = Role.technical_inspector.name
      @new_status = IssueStatus.technical_review
      @new_assigned_to = set_assigned_to(Role.technical_inspector)
      @forward_issue = true

    end

    if @issue.status == IssueStatus.request_adjustment
      @new_role_name = Role.requester.name
      @new_assigned_to = set_assigned_to(Role.requester)
      @issue.assigned_to == @new_assigned_to ? @forward_issue = false : @forward_issue = true
    
    end

    if @issue.status == IssueStatus.approve

      if @user_roles.include?(Role.technical_inspector)
        @new_role_name = Role.contract_manager.name
        @new_status = IssueStatus.managerial_review
        @new_assigned_to = set_assigned_to(Role.contract_manager)
        @forward_issue = true
      
      elsif @user_roles.include?(Role.contract_manager)
        @new_role_name = Role.agent.name
        @new_status = IssueStatus.ready_for_workplan
        @new_assigned_to = set_assigned_to(Role.agent)  
        @forward_issue = true     
      
      end
    end

    if @issue.status == IssueStatus.develop_work_plan
      @new_role_name = Role.scrum_master.name
      @new_assigned_to = set_assigned_to(Role.scrum_master)
      @new_status = IssueStatus.plan_drafting
      @forward_issue = true    
    end

    if @issue.status == IssueStatus.request_work_plan_approval
      work_plan = @issue.work_plan
      work_plan.status = 'planned'
      work_plan.save!
      @new_role_name = Role.technical_inspector.name
      @new_assigned_to = set_assigned_to(Role.technical_inspector)
      @new_status = IssueStatus.technical_plan_review
      @forward_issue = true
    end

    puts "Issue prepared to forward" if @forward_issue
  end
end


####################### AFTER SAVE ######################
if @forward_issue

  if @new_status.present?
    @issue.update_columns(status_id: @new_status.id)
  end

  if @new_assigned_to.present?
    @issue.update_columns(assigned_to_id: @new_assigned_to.id)
    self.custom_workflow_messages[:warning] = l(:warning_cw_issue_assigned_to_updated_to, role_name: @new_role_name)
  end

  @issue.current_journal.save(:validate => false)

  puts "Issue forwarded"
end
