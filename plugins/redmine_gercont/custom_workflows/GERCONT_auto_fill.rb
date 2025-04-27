if @issue.contracts_any?

  unless @issue.is_demand?
    @selected_sprint = @issue.sprint
    if @issue.parent.present?
      @issue.sprint = @issue.parent.sprint
    else
      @issue.sprint = @issue.product_backlog
    end
  end

  puts "Issue fields filled-up" if selected_sprint_changed?
end

