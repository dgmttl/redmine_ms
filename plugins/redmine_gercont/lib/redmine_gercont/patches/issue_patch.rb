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
              @assignable_versions = project.versions.planning + project.versions.rejected
            end
          end

          def product_backlog
            project.product_backlogs.find { |backlog| backlog.name == self.to_s.split(':')[0] } ||
            project.product_backlogs.first
          end

          def contracts_any?
            project.contracts.any?
          end

        end
      end
    end
  end
end

Issue.send(:include, RedmineGercont::Patches::IssuePatch)