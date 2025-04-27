module WorkPlansHelper

    def demand_options
        issues = @project.issues.where(
            tracker_id: Setting.plugin_redmine_gercont['demand_tracker_id']
            ).map { |issue| [issue.to_s, issue.id] }
            
        busy = WorkPlan.pluck(:issue_id)
      
        available = issues.reject { |_, issue_id| busy.include?(issue_id) }
      
        current_issue = @work_plan.issue
        if current_issue && !available.map(&:last).include?(current_issue.id)
          available << [current_issue.to_s, current_issue.id]
        end
      
        available
    end

    def issue_work_plan_path        
        issue_path(@issue, :tab => 'work_plan')
    end

    def can_plan_work_plan?
        ((@issue.work_plan.present? && ['planning', 'rejected'].include?(@issue.work_plan.status))  &&
        User.current.allowed_to?(:plan_work_plan, @project)) || User.current.admin?
    end

    def can_approve_work_plan?
       ((@issue.work_plan.present? && @issue.work_plan.status == 'planned')  &&
        User.current.allowed_to?(:approve_work_plan, @project)) || User.current.admin?
    end

    def can_generate_work_order?
      ((@issue.work_plan.present? && @issue.work_plan.status == 'approved')  &&
      User.current.allowed_to?(:generate_work_order, @project)) || User.current.admin?
    end

end