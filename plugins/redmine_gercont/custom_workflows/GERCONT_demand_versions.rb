if @issue.tracker_id == @demand && @issue.contracts_any?

  if @issue.sprint.blank? && @issue.children?
      @issue.sprint = @issue.children.first.sprint
  end

  if @issue.status_id == @request_approval 
    
    if (@issue.assigned_to.present? &&
      !@issue.assigned_to.roles_for_project(@issue.project)
        .any? { |role| role&.name == l(:default_role_technical_inspector) }) ||
      @issue.assigned_to.nil?
    
      @issue.assigned_to = @issue.project.users.find do |u|
        roles = u.roles_for_project(@issue.project)
        roles && roles.any? { |role| role&.name == l(:default_role_technical_inspector) }
      end
      self.custom_workflow_messages[:warning] = l(:warning_cw_issue_assigned_to_updated_to_technical_inspector)
    end
  end

  if (@issue.status_changed? && @issue.status_id == @request_approval) || requested_versions_changed?
    
    @versions_in = requested_versions_is - requested_versions_was
    @versions_out = requested_versions_was - requested_versions_is

    @stories_to_demand.concat(
      stories_by_version_ids(@versions_in).map do |story|
        story
      end
    ) if @versions_in.present?

    @stories_out_demand.concat(
      stories_by_version_ids(@versions_out).map do |story|
        story
      end
    )if @versions_out.present?

  end
end


#################################AFTER SAVE###################
if @stories_to_demand.present? && @issue.sprint.blank?
  demand_backlog = create_demand_backlog
else
  demand_backlog = @issue.sprint
end

puts "=============== demand_backlog: #{demand_backlog.inspect}"

if @stories_to_demand.present?
  @stories_to_demand.each do |story|
    story.parent = @issue
    story.sprint = demand_backlog
    story.custom_field_values=({@field_for_issue_in_pbi => false})
    story.save!


  end 
end

Version.where(id: @versions_in).update_all(status: 'requested')
Version.where(id: @versions_out).update_all(status: 'planning')

if @stories_out_demand.present?
  @stories_out_demand.each do |story|
      story.parent_id = nil
      story.sprint = @issue.project.product_backlogs.first
      story.custom_field_values=({@field_for_issue_in_pbi => true})
      story.save!
  end 
end