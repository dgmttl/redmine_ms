@user_roles = @issue.present? ? User.current.membership(@issue.project).try(:roles) : []
@selected_sprint = nil

# After save items
@stories_to_demand = []
@stories_out_demand = []
@default_pbl = nil
@requested = nil
@aproved = nil
@forward_issue = false
@new_status = nil
@new_role = nil
@new_assigned_to = nil