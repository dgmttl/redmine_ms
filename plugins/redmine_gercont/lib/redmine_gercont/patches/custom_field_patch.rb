module RedmineGercont
  module Patches
    module CustomFieldPatch
      def self.included(base)
        base.class_eval do
          # Métodos de classe que retornam o objeto correspondente
          def self.version_count
            find_by(id: Setting.plugin_redmine_gercont["field_for_version_count"].to_i)
          end

          def self.version_duration
            find_by(id: Setting.plugin_redmine_gercont["field_for_version_duration"].to_i)
          end

          def self.version_cost
            find_by(id: Setting.plugin_redmine_gercont["field_for_version_cost"].to_i)
          end

          def self.requested_versions
            find_by(id: Setting.plugin_redmine_gercont["field_for_requested_versions"].to_i)
          end

          def self.story_points
            find_by(id: Setting.plugin_scrum["story_points_custom_field_id"].to_i)
          end

          def self.blocked_story
            find_by(id: Setting.plugin_scrum["blocked_custom_field_id"].to_i)
          end

          def self.requester_unity
            find_by(id: Setting.plugin_redmine_gercont["field_for_requester_unity"].to_i)
          end

        end
      end
    end
  end
end

CustomField.send(:include, RedmineGercont::Patches::CustomFieldPatch)