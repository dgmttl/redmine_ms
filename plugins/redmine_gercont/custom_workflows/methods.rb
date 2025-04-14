
def requested_versions_was
    custom_field_values.detect { |v| v.custom_field_id == @field_for_requested_versions }.value_was
end

def requested_versions_is
    @issue.custom_field_values.detect { |v| v.custom_field_id == @field_for_requested_versions }.value
end

def requested_versions_changed?
    requested_versions_was != requested_versions_is
end

 
def stories_by_version_ids(version_ids)
    versions = Version.where(id: version_ids)
    story_ids = versions.map do |v|
        v.fixed_issue_ids
    end.flatten

    Issue.where(id: story_ids)
end

def create_demand_backlog(issue)
    @demand_backlog = Sprint.new(
        name: issue.to_s.split(':')[0],
        description: "[#{l(:label_view)} #{issue.to_s.split(':')[0]}](/issues/#{issue.id})",
        status: 'open',
        shared: '0',
        is_product_backlog: 'true',
        project: issue.project,
        sprint_start_date: Date.today,
        sprint_end_date: Date.today,
        user: User.current,
    )
    @demand_backlog.save!
  end

