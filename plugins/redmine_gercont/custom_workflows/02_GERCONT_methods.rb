
def requested_versions_was
    @issue.custom_field_values.detect { |v| v.custom_field_id == @field_for_requested_versions }.value_was
end

def requested_versions_is
    @issue.custom_field_values.detect { |v| v.custom_field_id == @field_for_requested_versions }.value
end

def requested_versions_changed?
    requested_versions_was != requested_versions_is
end

 
def stories_by_version_ids(version_ids)
    versions = Version.where(id: version_ids.map(&:to_i))
    puts "==================== stories_by_version_ids - versions: #{versions}"
    story_ids = versions.map do |v|
        v.fixed_issue_ids
    end.flatten

    puts "==================== stories_by_version_ids - story_ids: #{story_ids}"

    Issue.where(id: story_ids)
end

def create_demand_backlog

    puts "======================== @issue: #{@issue}"
    name = @issue.to_s.split(':')[0]
    puts "======================== nome: #{name}"
    puts "======================== description: [#{l(:label_view)} #{@issue.to_s.split(':')[0]}](/issues/#{@issue.id})"
    demand_backlog = Sprint.create(
        name: name,
        description: "[#{l(:label_view)} #{@issue.to_s.split(':')[0]}](/issues/#{@issue.id})",
        # description: "[#{l(:label_view)} #{name}](/issues/#{@issue.id})",
        status: 'open',
        shared: '0',
        is_product_backlog: 'true',
        project: @issue.project,
        sprint_start_date: Date.today,
        sprint_end_date: Date.today,
        user: User.current
    )
    puts "================== create_demand_backlog - @demand_backlog: #{demand_backlog}"
   
    demand_backlog
  end

