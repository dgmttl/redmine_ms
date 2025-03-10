
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



