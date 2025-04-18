if @issue.tracker_id == @demand && @issue.project.contracts.present?

  if (@issue.status_changed? && @issue.status_id == @request_approval) || requested_versions_changed?
    
    @issue.sprint = @issue.product_backlog if @issue.sprint.blank? && @issue.children?
    
    puts "====================== l(:default_role_technical_inspector) #{ l(:default_role_technical_inspector)} ========="
    technical_inspector = User.new
    if @issue.status_id == @request_approval
      
      technical_inspector = @issue.project.users.find do |u|
        roles = u.roles_for_project(@issue.project)
        roles && roles.any? { |role| role&.name == 'Fiscal Técnico' }
      end
      
      puts "====================== Fiscal Técnico #{ technical_inspector.name} ================="
    end
    @issue.assigned_to_id = technical_inspector.id

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
demand_backlog = @issue.sprint
demand_backlog = create_demand_backlog if @issue.sprint.blank?

puts

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