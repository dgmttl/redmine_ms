if @issue.contracts_any?

    if @issue.is_demand?
        if @issue.status == IssueStatus.develop_work_plan
            if @issue.work_plan.blank?
                create_work_plan
                puts "Work Plan created"
            end
        end
    end
end