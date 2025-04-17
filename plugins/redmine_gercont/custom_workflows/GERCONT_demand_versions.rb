if !new_record? && @issue.tracker_id == @demand && @issue.project.contracts.present?

  puts "================ @issue.product_backlog #{@issue.product_backlog}"
  puts "================ @issue.sprint #{@issue.sprint}"

  @demand_backlog = @issue.sprint
  if @demand_backlog.blank?
    @demand_backlog = create_demand_backlog 
    @issue.sprint = @demand_backlog
  end
  
  puts "================ DEMAND_BACKLOG: #{@demand_backlog}"

  if ( self.status_changed? && self.status_id == @request_approval) || requested_versions_changed?
  
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

puts "=================== AFTER SAVE: @demand_backlog: #{@demand_backlog}"
puts "=================== AFTER SAVE: @demand_backlog.present?: #{@demand_backlog.present?}"

puts "=================== AFTER SAVE: @stories_to_demand: #{@stories_to_demand}"
puts "=================== AFTER SAVE: @stories_out_demand: #{@stories_out_demand}"


@stories_to_demand.each do |story|
  story.parent = self
  story.sprint= @demand_backlog
  story.custom_field_values=({@field_for_issue_in_pbi => false})
  story.save!
end if @stories_to_demand.present?

Version.where(id: @versions_in).update_all(status: 'requested')
Version.where(id: @versions_out).update_all(status: 'planning')

@stories_out_demand.each do |story|
    story.parent_id= nil
    story.sprint_id= self.project.product_backlogs.first.id
    story.custom_field_values=({@field_for_issue_in_pbi => true})
    story.save!
end if @stories_out_demand.present?
