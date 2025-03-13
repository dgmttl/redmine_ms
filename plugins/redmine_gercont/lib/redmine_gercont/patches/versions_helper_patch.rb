module RedmineGercont
  module Patches
    module VersionsHelperPatch
      def self.included(base)
        base.class_eval do
          
          def sum_estimated_counts(versions)
            versions.sum do |version|
              custom_value = version.custom_value_for(Setting.plugin_redmine_gercont['field_for_version_count'])
              custom_value ? custom_value.value.tr(",", ".").to_f.round(2) : 0
            end
          end

          def sum_estimated_durations(versions)
            versions.sum do |version|
              custom_value = version.custom_value_for(Setting.plugin_redmine_gercont['field_for_version_duration'])
              custom_value ? custom_value.value.tr(",", ".").to_f.round(2) : 0
            end
          end

          def sum_estimated_costs(versions)
            versions.sum do |version|
              custom_value = version.custom_value_for(Setting.plugin_redmine_gercont['field_for_version_cost'])
              custom_value ? custom_value.value.tr(",", ".").to_f.round(2) : 0
            end
          end

          def sum_related_stories(versions)
            versions.sum do |version|
              Issue.where(fixed_version_id: version.id, tracker_id: Scrum::Setting.pbi_tracker_ids.first).count
            end
          end

       
          def plan_status_classes(versions)
            versions = Array(versions)
            status = Version.plan_status(versions)
            "badge-status-#{status}"
          end
        
          def can_approve_plan?
            (@project.versions.any? { |version| ['planned', 'rejected'].include?(version.status) } &&
              User.current.allowed_to?(:approve_plan, @project)) || User.current.admin?
          end

          def can_ask_for_approval?
            (@project.versions.any? { |version| ['planning', 'rejected'].include?(version.status) }  &&
            User.current.allowed_to?(:ask_for_plan_approval, @project)  ) || User.current.admin?
          end

          def link_to_demand(version)
            on_status = ['requested', 'open', 'locked', 'closed']
            demand = @project.issues.where(tracker_id: Setting.plugin_redmine_gercont['demand_tracker_id']).find do |demand| 
              demand.custom_field_value(Setting.plugin_redmine_gercont['field_for_requested_versions'])
                .include?(version.id.to_s) 
            end

            if demand && on_status.include?(version.status)
              link_to("#{l(:label_view)} #{demand.tracker}", issue_path(demand), class: 'demand-link').html_safe
            else
              ""
            end
          end

          def project_type
            cf_id = @project.custom_field_value(Setting.plugin_redmine_gercont['field_for_project_type'])
            CustomFieldEnumeration.find(cf_id).position
          end

          def estimative_field_ids
            field_ids = []
            field_ids << Setting.plugin_redmine_gercont['field_for_version_count']
            field_ids << Setting.plugin_redmine_gercont['field_for_version_duration']
            field_ids << Setting.plugin_redmine_gercont['field_for_version_cost']
            field_ids.map(&:to_i)
          end

        end
      end
    end
  end
end

VersionsHelper.send(:include, RedmineGercont::Patches::VersionsHelperPatch)