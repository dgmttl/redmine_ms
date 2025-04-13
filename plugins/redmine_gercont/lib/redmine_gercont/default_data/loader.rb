module RedmineGercont
  module DefaultData
    class DataAlreadyLoaded < StandardError; end

    module Loader
      include Redmine::I18n

      class << self
        # Returns true if no data is already loaded in the database
        # otherwise false
        def no_data?
          !Role.where(:builtin => 0).exists? &&
            !Tracker.exists? &&
            !IssueStatus.exists? &&
            !Enumeration.exists? &&
            !Query.exists?
        end

        # Loads the default data
        # Raises a RecordNotSaved exception if something goes wrong
        def load(lang=nil, options={})
          raise DataAlreadyLoaded.new("Some configuration data is already loaded.") unless no_data?
          set_language_if_valid(lang)
          workflow = !(options[:workflow] == false)

          # Enumerations
          IssuePriority.create!(:name => l(:default_priority_low), :position => 1)
          IssuePriority.create!(:name => l(:default_priority_normal), :position => 2, :is_default => true)
          IssuePriority.create!(:name => l(:default_priority_high), :position => 3)
          IssuePriority.create!(:name => l(:default_priority_urgent), :position => 4)
          IssuePriority.create!(:name => l(:default_priority_immediate), :position => 5)

          # story and tasks statuses
          new = IssueStatus.create!(
            :name => l(:default_issue_status_new), 
            :is_closed => false, 
            :position => 1,
            :default_done_ratio => 0
          )

          in_progress = IssueStatus.create!(
            :name => l(:default_issue_status_in_progress), 
            :is_closed => false, 
            :position => 2,
            :default_done_ratio => 50
          )

          resolved = IssueStatus.create!(
            :name => l(:default_issue_status_resolved), 
            :is_closed => false, 
            :position => 3,
            :default_done_ratio => 80
          )

          feedback = IssueStatus.create!(
            :name => l(:default_issue_status_feedback), 
            :is_closed => false, 
            :position => 4,
            :default_done_ratio => 70
          )

          closed = IssueStatus.create!(
            :name => l(:default_issue_status_closed), 
            :is_closed => true, 
            :position => 5,
            :default_done_ratio => 100
          )
          
          rejected = IssueStatus.create!(
            :name => l(:default_issue_status_rejected), 
            :is_closed => true, 
            :position => 6,
            :default_done_ratio => 100
            )

          # Demand statuses
          request_approval        = IssueStatus.create!(:name => l(:default_issue_status_request_approval), :is_closed => false, :position => 7)
          request_adjust          = IssueStatus.create!(:name => l(:default_issue_status_request_adjustment), :is_closed => false, :position => 8)
          approve                 = IssueStatus.create!(:name => l(:default_issue_status_approve), :is_closed => false, :position => 9)
          develop_work_plan       = IssueStatus.create!(:name => l(:default_issue_status_develop_work_plan), :is_closed => false, :position => 10)
          approve_work_plan       = IssueStatus.create!(:name => l(:default_issue_status_approve_work_plan), :is_closed => false, :position => 11)
          generate_work_order     = IssueStatus.create!(:name => l(:default_issue_status_generate_work_order), :is_closed => false, :position => 12)
          allocate_professionals  = IssueStatus.create!(:name => l(:default_issue_status_allocate_professionals), :is_closed => false, :position => 13)
          delivered               = IssueStatus.create!(:name => l(:default_issue_status_delivered), :is_closed => false, :position => 14)
          accepted               = IssueStatus.create!(:name => l(:default_issue_status_accepted), :is_closed => false, :position => 15)
          
          
          # Trackers - falta campos padrão
          demand = Tracker.create!(
            :name => l(:default_tracker_demand), 
            :default_status_id => new.id, 
            :is_in_roadmap => false, 
            :position => 1,
            :core_fields => [
              "assigned_to_id", 
              "fixed_version_id", 
              "start_date", 
              "due_date", 
              "estimated_hours", 
              "done_ratio", 
              "description", 
              "priority_id"
            ]
          )

          story = Tracker.create!(
            :name => l(:default_tracker_story), 
            :default_status_id => new.id, 
            :is_in_roadmap => true, 
            :position => 2,
            :core_fields => [
              "assigned_to_id", 
              "fixed_version_id", 
              "parent_issue_id", 
              "start_date", 
              "due_date", 
              "estimated_hours", 
              "done_ratio", 
              "description", 
              "priority_id"
            ]
          )

          task = Tracker.create!(
            :name => l(:default_tracker_task), 
            :default_status_id => new.id, 
            :is_in_roadmap => false, 
            :position => 3,
            :core_fields => [
              "assigned_to_id", 
              "parent_issue_id", 
              "start_date", 
              "due_date", 
              "done_ratio", 
              "description", 
              "priority_id"
            ]
          )

          # Roles
          Role.transaction do
            contract_admin = Role.create!(
              :name => l(:default_role_contract_admin),
              :position => 1,
              :assignable => false,
              :permissions => [
                :add_project, 
                :edit_project, 
                :close_project, 
                :manage_members, 
                :add_subprojects, 
                :manage_project_workflow, 
                :view_contract, 
                :manage_contract, 
                :view_issues
              ],
              :issues_visibility => "all",
              :users_visibility => "all",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"1", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "add_issues"=>[], 
                  "edit_issues"=>[], 
                  "add_issue_notes"=>[], 
                  "delete_issues"=>[]
                }
              }
            )

            contract_manager = Role.create!(
              :name => l(:default_role_contract_manager),
              :position => 2,
              :assignable => true,
              :permissions => [
                :view_contract,
                :view_issues,
                :edit_issues,
                :add_issue_notes,
                :edit_own_issue_notes,
                :view_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                },
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "edit_issues"=>[demand.id],
                  "add_issue_notes"=>[demand.id], 
                  "add_issues"=>[], 
                  "delete_issues"=>[]
                }
              }
            )

            technical_inspector = Role.create!(
              :name => l(:default_role_technical_inspector),
              :position => 3,
              :assignable => true,
              :permissions => [
                :view_contract, 
                :view_issues, 
                :edit_issues, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "edit_issues"=>[demand.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "add_issues"=>[], 
                  "delete_issues"=>[]
                }
              }
            )

            administrative_inspector = Role.create!(
              :name => l(:default_role_administrative_inspector),
              :position => 4,
              :assignable => true,
              :permissions => [
                :view_issues
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "add_issues"=>[], 
                  "edit_issues"=>[], 
                  "add_issue_notes"=>[], 
                  "delete_issues"=>[]
                }
              }
            )

            requester = Role.create!(
              :name => l(:default_role_requester),
              :position => 5,
              :assignable => true,
              :permissions => [
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_product_backlog, 
                :edit_product_backlog, 
                :sort_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "add_issues"=>[demand.id, story.id], 
                  "edit_issues"=>[demand.id, story.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "delete_issues"=>[]
                }
              }
            )

            agent = Role.create!(
              :name => l(:default_role_agent),
              :position => 6,
              :assignable => false,
              :permissions => [
                :manage_members, 
                :view_issues, 
                :view_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "add_issues"=>[], 
                  "edit_issues"=>[], 
                  "add_issue_notes"=>[], 
                  "delete_issues"=>[]
                }
              }
            )

            product_owner = Role.create!(
              :name => l(:default_role_product_owner),
              :position => 7,
              :assignable => true,
              :permissions => [
                :manage_versions, 
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :manage_issue_relations, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_product_backlog, 
                :check_dependencies, 
                :edit_product_backlog, 
                :sort_product_backlog, 
                :view_release_plan
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "add_issues"=>[demand.id, story.id], 
                  "edit_issues"=>[demand.id, story.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "delete_issues"=>[]
                }
              }
            )

            scrum_master = Role.create!(
              :name => l(:default_role_scrum_master),
              :position => 8,
              :assignable => true,
              :permissions => [
                :manage_members, 
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :manage_issue_relations, 
                :manage_subtasks, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :manage_sprints, 
                :view_sprint_board, 
                :edit_sprint_board, 
                :sort_sprint_board, 
                :view_product_backlog, 
                :edit_product_backlog, 
                :sort_product_backlog, 
                :view_release_plan
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "edit_issues"=>[demand.id, story.id, task.id], 
                  "add_issue_notes"=>[demand.id, story.id, task.id], 
                  "add_issues"=>[story.id, task.id], 
                  "delete_issues"=>[]
                }
              }
            )

            scrum_team = Role.create!(
              :name => l(:default_role_scrum_team),
              :position => 9,
              :assignable => true,
              :permissions => [
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :edit_own_issues, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_sprint_board, 
                :edit_sprint_board, 
                :sort_sprint_board, 
                :view_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "edit_issues"=>[demand.id, story.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "add_issues"=>[task.id], 
                  "delete_issues"=>[]
                }
              }
            )

            agent.update(managed_role_ids: [agent.id, scrum_master.id, scrum_team.id])
            scrum_master.update(managed_role_ids: [scrum_master.id, scrum_team.id])


            # Custom fields
            story_points = IssueCustomField.create!(
              :field_format => 'list',
              :name => l(:default_field_story_points),
              :possible_values => ['1', '2', '3', '5', '8', '13','21'],
              :is_filter => 1,
              :visible => 1,
              :tracker_ids => [story.id], 
              :is_for_all => 1
            )

            blocked = IssueCustomField.create!(
              :field_format => 'bool',
              :name => l(:default_field_blocked),
              :edit_tag_style => 'radio',
              :is_required => 1,
              :default_value => '0',
              :is_filter => 1,
              :visible => 1,
              :tracker_ids => [story.id], 
              :is_for_all => 1
            )

            
            releases = IssueCustomField.create!(
              :field_format => 'version',
              :name => l(:default_field_versions),
              :edit_tag_style => 'check_box',
              :is_required => 1,
              :visible => 1,
              :tracker_ids => [demand.id], 
              :is_for_all => 1,
              :version_status => ["planning", "planned", "rejected"]
            )

            non_funcional_requirements = IssueCustomField.create!(
              :field_format => 'text',
              :name => l(:default_field_non_functional_requirements),
              :is_required => 1,
              :searchable => 1,
              :visible => 1,
              :tracker_ids => [demand.id], 
              :is_for_all => 1
            )

            type = ProjectCustomField.create!(
              :field_format => 'enumeration',
              :name => l(:default_field_project_type),
              :multiple => 1,
              :is_required => 1,
              :visible => 1
            )

            CustomFieldEnumeration.create!(
              :name => l(:default_field_project_type_development),
              :custom_field => type
            )
            CustomFieldEnumeration.create!(
              :name => l(:default_field_project_type_maintenance),
              :custom_field => type
            )

            requester_unity = ProjectCustomField.create!(
              :field_format => 'list',
              :name => l(:default_field_requester_unity),
              :possible_values => ['first', 'second', 'third', 'and so on...'],
              :is_required => 1,
              :is_filter => 1,
              :visible => 1
            )

            estimated_count = VersionCustomField.create!(
              :field_format => 'float',
              :name => l(:default_field_estimated_count),
              :thousands_delimiter => 1,
              :visible => 1
            )

            estimated_duration = VersionCustomField.create!(
              :field_format => 'int',
              :name => l(:default_field_estimated_duration),
              :thousands_delimiter => 1,
              :visible => 1
            )

            estimated_cost = VersionCustomField.create!(
              :field_format => 'float',
              :name => l(:default_field_estimated_cost),
              :thousands_delimiter => 1,
              :visible => 1
            )

            # Plugin settings 
            gercont_settings = {
              :demand_tracker_id => demand.id.to_s,
              :role_for_contract_manager => contract_manager.id.to_s,
              :role_for_technical_inspector => technical_inspector.id.to_s,      
              :role_for_administrative_inspector => administrative_inspector.id.to_s,
              :role_for_agent => agent.id.to_s,
              :role_for_product_owner => product_owner.id.to_s,
              :role_for_contract_admin => contract_admin.id.to_s,
              :role_for_requester => requester.id.to_s,
              :roles_for_assessment => [scrum_team.id].map(&:to_s),     
              :statuses_for_edit_assessment => [delivered.id].map(&:to_s),    
              :field_for_version_count => estimated_count.id.to_s,
              :field_for_version_duration => estimated_duration.id.to_s,        
              :field_for_version_cost => estimated_cost.id.to_s,
              :field_for_requested_versions => releases.id.to_s,
              :field_for_requester_unity => requester_unity.id.to_s,
              :field_for_project_type => type.id.to_s,
              :field_for_non_functional_requirements => non_funcional_requirements.id.to_s,
            }.transform_keys(&:to_s)

            Setting.send :plugin_redmine_gercont=, gercont_settings 
            scrum_settings = {
              :sprint_burndown => '0',
              :render_plugin_tips => '0',
              :story_points_custom_field_id => story_points.id.to_s,
              :blocked_custom_field_id => blocked.id.to_s,
              :simple_pbi_custom_field_id => '',
              :pbi_tracker_ids => [story.id].map(&:to_s),
              :task_tracker_ids => [task.id].map(&:to_s),
              "tracker_#{story.id}_fields".to_sym => ["description"],
              "tracker_#{task.id}_fields".to_sym => ["assigned_to_id", "category_id", "due_date", "done_ratio", "description"],
              :auto_update_pbi_status => '0',
              :closed_pbi_status_id => '',
              :pbi_is_closed_if_tasks_are_closed => '0',
              :use_remaining_story_points => '0',
              :default_sprint_name => 'Sprint 1',
              :default_sprint_days => '5',
              :default_sprint_shared => '0',
              :postit_size => 'big',
              :random_posit_rotation => '1',
              "tracker_#{story.id}_color".to_sym => 'post-it-color-1',
              "tracker_#{task.id}_color".to_sym => 'post-it-color-2',
              :doer_color => 'post-it-color-5',
              :reviewer_color => 'post-it-color-3',
              :doer_reviewer_postit_user_field_id => '',
              :task_status_ids => [new.id, in_progress.id, resolved.id, feedback.id, closed.id].map(&:to_s),
              :clear_new_tasks_assignee => '0',
              :pbi_status_ids => [new.id, in_progress.id, resolved.id, feedback.id, closed.id].map(&:to_s),
              :inherit_pbi_attributes => '1',
              :lowest_speed => '70',
              :low_speed => '80',
              :high_speed => '140',
              :render_pbis_speed => '1',
              :render_tasks_speed => '1',
              "tracker_#{story.id}_sprint_board_fields".to_sym => ["fixed_version_id"],
              "tracker_#{task.id}_sprint_board_fields".to_sym => ["category_id"],
              :show_project_totals_on_sprint => '1',
              :sprint_burndown_day_zero => '1',
              :create_journal_on_pbi_position_change => '0',
              :check_dependencies_on_pbi_sorting => '0',
              :render_position_on_pbi => '1',
              :render_category_on_pbi => '1',
              :render_version_on_pbi => '1',
              :render_author_on_pbi => '0',
              :render_assigned_to_on_pbi => '0',
              :render_updated_on_pbi => '0',
              :show_project_totals_on_backlog => '0',
              :product_burndown_sprints => '4',
              :product_burndown_extra_sprints => '3',
              :product_backlog_default_velocity => '26'
          }.transform_keys(&:to_s)
            Setting.send :plugin_scrum=, scrum_settings

            #users            
            ContractMember.role_options.map(&:name).each do |name|
              user = User.create!(
                :login => generate_login(name),
                :firstname => name.split.first.capitalize,
                :lastname => name.split.last.capitalize,
                :mail => "#{generate_login(name)}@gercont.com"
              )
              
              user.password = '12345678'
              user.password_confirmation = '12345678'
              user.save
            end

            #General Settings
            Setting.default_language = 'pt-BR'
            Setting.new_project_user_role_id = contract_admin.id
            Setting.issue_done_ratio = 'issue_status'

            # Fields visibility
            trackers = [demand, story, task]
            core_fields = trackers.map(&:core_fields).flatten.uniq
            custom_fields_id = trackers.map(&:custom_fields).flatten.map(&:id).uniq.sort
            fields = ['project_id', 'tracker_id', 'subject', 'is_private'] + core_fields + custom_fields_id 
            roles = [
              contract_admin, contract_manager, technical_inspector,
              administrative_inspector, requester, agent,
              product_owner, scrum_master, scrum_team
            ]
            statuses = [
              new, in_progress, resolved, feedback, closed, rejected,
              request_approval, request_adjust, approve, develop_work_plan,
              approve_work_plan, generate_work_order, allocate_professionals,
              delivered, accepted
            ].map(&:id)

            # Workflow permissions
            permissions = statuses.each_with_object({}) do |status, permissions_hash|
              permissions_hash[status] = {}

              # Atribuímos "readonly" a todos os campos em `fields`
              fields.each do |field|
                permissions_hash[status][field] = "readonly"
              end
            end

            WorkflowPermission.replace_permissions(trackers, roles, permissions)


            # Requester workflow for story
            WorkflowTransition.create!(
              :tracker_id => story.id, 
              :role_id => requester.id,
              :old_status_id => new.id,
              :new_status_id => rejected.id
            )
            WorkflowTransition.create!(
              :tracker_id => story.id, 
              :role_id => requester.id,
              :old_status_id => resolved.id,
              :new_status_id => feedback.id
            )
            WorkflowTransition.create!(
              :tracker_id => story.id, 
              :role_id => requester.id,
              :old_status_id => resolved.id,
              :new_status_id => closed.id
            )

            WorkflowPermission.replace_permissions(
              story,
              requester,
              new.id.to_s => {
                "tracker_id" => "",
                "subject" => "",
                "assigned_to_id" => ""
              }
            )

            # Custom Workflows
            CustomWorkflow.first.destroy if CustomWorkflow.first.present?
            files = Dir.glob(File.join(Rails.root, 'plugins', 'redmine_gercont', 'lib', 'redmine_gercont', 'default_data', 'cw_scripts', '*.xml'))
            files.each do |file|
              workflow = CustomWorkflow.import_from_xml(File.read(file))
              workflow.string=''
              workflow.save
            end


            # Issue queries
            IssueQuery.create!(
              :name => l(:label_assigned_to_me_issues),
              :filters =>
                {
                  'status_id' => {:operator => 'o', :values => ['']},
                  'assigned_to_id' => {:operator => '=', :values => ['me']},
                  'project.status' => {:operator => '=', :values => ['1']}
                },
              :sort_criteria => [['priority', 'desc'], ['updated_on', 'desc']],
              :visibility => Query::VISIBILITY_PUBLIC
            )
            IssueQuery.create!(
              :name => l(:label_reported_issues),
              :filters =>
                {
                  'status_id' => {:operator => 'o', :values => ['']},
                  'author_id' => {:operator => '=', :values => ['me']},
                  'project.status' => {:operator => '=', :values => ['1']}
                },
              :sort_criteria => [['updated_on', 'desc']],
              :visibility => Query::VISIBILITY_PUBLIC
            )
            IssueQuery.create!(
              :name => l(:label_updated_issues),
              :filters =>
                {
                  'status_id' => {:operator => 'o', :values => ['']},
                  'updated_by' => {:operator => '=', :values => ['me']},
                  'project.status' => {:operator => '=', :values => ['1']}
                },
              :sort_criteria => [['updated_on', 'desc']],
              :visibility => Query::VISIBILITY_PUBLIC
            )
            IssueQuery.create!(
              :name => l(:label_watched_issues),
              :filters =>
                {
                  'status_id' => {:operator => 'o', :values => ['']},
                  'watcher_id' => {:operator => '=', :values => ['me']},
                  'project.status' => {:operator => '=', :values => ['1']},
                },
              :sort_criteria => [['updated_on', 'desc']],
              :visibility => Query::VISIBILITY_PUBLIC
            )

            # Project queries
            ProjectQuery.create!(
              :name => l(:label_my_projects),
              :filters =>
                {
                  'status' => {:operator => '=', :values => ['1']},
                  'id' => {:operator => '=', :values => ['mine']}
                },
              :visibility => Query::VISIBILITY_PUBLIC
            )
            ProjectQuery.create!(
              :name => l(:label_my_bookmarks),
              :filters =>
                {
                  'status' => {:operator => '=', :values => ['1']},
                  'id' => {:operator => '=', :values => ['bookmarks']}
                },
              :visibility => Query::VISIBILITY_PUBLIC
            )
          end
          true
        end

        
        def generate_login(name)
          parts = name.split.map { |part| I18n.transliterate(part) }
          "#{parts.first.downcase}.#{parts.last.downcase}"
        end
      end
    end
  end
end
