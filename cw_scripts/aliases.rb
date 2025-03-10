# Plugin attributes
@demand = Setting.plugin_redmine_gercont["role_for_contract_manager"]
@role_for_product_owner = Setting.plugin_redmine_gercont["role_for_product_owner"]
@role_for_requester = Setting.plugin_redmine_gercont["role_for_requester"]
@roles_for_assessment= Setting.plugin_redmine_gercont["roles_for_assessment"].map(&:to_i)
@statuses_for_edit_assessment= Setting.plugin_redmine_gercont["statuses_for_edit_assessment"].map(&:to_i)
@role_for_contract_manager = Setting.plugin_redmine_gercont["role_for_contract_manager"]
@role_for_technical_inspector = Setting.plugin_redmine_gercont["role_for_technical_inspector"]
@role_for_administrative_inspector = Setting.plugin_redmine_gercont["role_for_administrative_inspector"]
@role_for_agent = Setting.plugin_redmine_gercont["role_for_agent"].to_i
@role_for_contract_admin = Setting.plugin_redmine_gercont["role_for_contract_admin"]


# Custom fields
@field_for_version_count = Setting.plugin_redmine_gercont["field_for_version_count"].to_i
@field_for_version_duration = Setting.plugin_redmine_gercont["field_for_version_duration "].to_i
@field_for_version_cost = Setting.plugin_redmine_gercont["field_for_version_cost"].to_i
@field_for_requested_versions= Setting.plugin_redmine_gercont["field_for_requested_versions"].to_i
@field_for_story_points = Setting.plugin_scrum["story_points_custom_field_id"].to_i
@field_for_blocked_story = Setting.plugin_scrum["blocked_custom_field_id"].to_i


# After save items
@stories_to_save_after = []