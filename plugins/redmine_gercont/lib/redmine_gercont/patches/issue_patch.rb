module RedmineGercont
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          has_one :work_order
          has_many :work_order_professionals, through: :work_order
          has_many :assessments, through: :work_order, source: :work_order_professionals
          has_many :sla_events, through: :work_order
          has_one :work_plan
          has_many :work_plan_items, through: :workplan

          

          alias_method :original_assignable_versions, :assignable_versions
          def assignable_versions
            original_assignable_versions
            unless project.contracts.empty?
              @assignable_versions = project.versions.planning + project.versions.rejected + project.versions.requested
            end
          end

          def product_backlog
            project.product_backlogs.first
          end

          def demand_backlog
            project.product_backlogs.find { |backlog| backlog.name == self.to_s.split(':')[0] }
          end

          def contracts_any?
            project.contracts.any?
          end

          def active_contracts
            project.active_contracts
          end

          def is_demand?
            self.tracker_id == Setting.plugin_redmine_gercont['demand_tracker_id'].to_i
          end

          def is_story?
            self.tracker_id == Setting.plugin_scrum['pbi_tracker_ids'].first.to_i
          end

        end
      end
    end
  end
end

Issue.send(:include, RedmineGercont::Patches::IssuePatch)