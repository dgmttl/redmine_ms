module RedmineGercont
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do

          alias_method :original_show, :show
          def show
            unless @project.contracts.empty?
              @assessments = @issue.assessments
              @sla_events = @issue.sla_events
            end
            original_show
          end

          alias_method :original_bulk_edit, :bulk_edit
          def bulk_edit
            original_bulk_edit
            unless @project.contracts.empty?
              @versions = @project.versions.planning + @project.versions.rejected
            end
          end
        end
      end
    end
  end
end
  
IssuesController.send(:include, RedmineGercont::Patches::IssuesControllerPatch)

  