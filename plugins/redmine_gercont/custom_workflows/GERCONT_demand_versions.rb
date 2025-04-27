if @issue.contracts_any?

  if @issue.is_demand?
    @selected_sprint = @issue.sprint
    if @issue.sprint.blank? && @issue.children?
        @issue.sprint = @issue.children.first.sprint
    end

    if (@issue.status_changed? && @issue.status == IssueStatus.request_approval) || requested_versions_changed?

      field_for_requested_versions = CustomField.find(Setting.plugin_redmine_gercont["field_for_requested_versions"].to_i)
      
      @versions_in = requested_versions_is(CustomField.requested_versions) - requested_versions_was(CustomField.requested_versions)
      @versions_out = requested_versions_was(CustomField.requested_versions) - requested_versions_is(CustomField.requested_versions)

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
    puts "Issue sprint changed" if selected_sprint_changed?
    puts "Issue children in prepared" if @stories_to_demand.present?
    puts "Issue children out prepared" if @stories_out_demand.present?
  end
end


#################################AFTER SAVE###################
if @stories_to_demand.present? && @issue.sprint.blank?
  demand_backlog = create_demand_backlog
  puts "Backlog created"
else
  demand_backlog = @issue.sprint
end

if @stories_to_demand.present?
  @stories_to_demand.each do |story|
    story.parent = @issue
    story.sprint = demand_backlog
    story.save!
  end 
  Version.where(id: @versions_in).update_all(status: 'requested')
  puts "Issue children associated"
end

if @stories_out_demand.present?
  Version.where(id: @versions_out).update_all(status: 'planning')
  @stories_out_demand.each do |story|
      story.parent_id = nil
      story.sprint = @issue.product_backlog
      story.save!
  end
  puts "Issue children disassociated"
end
