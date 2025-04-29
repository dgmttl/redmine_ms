
def requested_versions_was(custom_field)
    @issue.custom_field_values.detect { |v| v.custom_field == custom_field }.value_was
end

def requested_versions_is(custom_field)
    @issue.custom_field_values.detect { |v| v.custom_field == custom_field }.value
end

def requested_versions_changed?
    requested_versions_was(CustomField.requested_versions) != requested_versions_is(CustomField.requested_versions)
end

 
def stories_by_version_ids(version_ids)
    versions = Version.where(id: version_ids.map(&:to_i))
    story_ids = versions.map do |v|
        v.fixed_issue_ids
    end.flatten

    Issue.where(id: story_ids)
end

def create_demand_backlog
    name = @issue.to_s.split(':')[0]
    demand_backlog = Sprint.create(
        name: name,
        description: "[#{l(:label_view)} #{name}](/issues/#{@issue.id})",
        status: 'open',
        shared: '0',
        is_product_backlog: 'true',
        project: @issue.project,
        sprint_start_date: Date.today,
        sprint_end_date: Date.today,
        user: User.current
    )   
    demand_backlog
end

def create_work_plan
    WorkPlan.create(
        issue_id: @issue.id,
        status: 'planning',
        updated_by: @issue.assigned_to
    )
end

def set_assigned_to(role)
    role_name = role.name
    if (@issue.assigned_to.present? &&
        !@issue.assigned_to.roles_for_project(@issue.project)
          .any? { |role| role&.name == role_name }) ||
        @issue.assigned_to.nil?
      
        @issue.project.users.find do |u|
          roles = u.roles_for_project(@issue.project)
          roles && roles.any? { |role| role&.name == role_name }
        end
    else
        @issue.assigned_to
    end

end

def selected_sprint_changed?
    @selected_sprint != @issue.sprint
  end

