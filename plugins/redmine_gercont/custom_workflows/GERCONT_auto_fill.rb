if @issue.contracts_any?

  unless @issue.demand?
    @selected_sprint = @issue.sprint
    if @issue.fixed_version.present?
      version = @issue.fixed_version
      issue = version.fixed_issues&.first
      @issue.parent = issue&.parent
    
      if @issue.parent.present?
        @issue.sprint = @issue.parent.sprint
      else
        @issue.sprint = @issue.product_backlog
      end
    end
  end

  puts "Issue fields filled-up" if selected_sprint_changed?
end

