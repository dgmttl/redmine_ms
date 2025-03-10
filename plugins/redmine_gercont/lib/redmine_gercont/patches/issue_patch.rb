module RedmineGercont
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          has_one :work_order
          has_many :assessments, through: :work_order, source: :work_order_professionals
          has_many :sla_events, through: :work_order
          has_one :work_plan

          alias_method :original_assignable_versions, :assignable_versions
          def assignable_versions
            original_assignable_versions
            unless project.contracts.empty?
              @assignable_versions = project.versions.planning + project.versions.rejected
            end
          end


        end
      end
    end
  end
end

Issue.send(:include, RedmineGercont::Patches::IssuePatch)