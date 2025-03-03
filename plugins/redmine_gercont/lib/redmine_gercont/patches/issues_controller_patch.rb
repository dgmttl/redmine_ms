module RedmineGercont
    module Patches
      module IssuesControllerPatch
        def self.included(base)
          base.class_eval do
  
            alias_method :show_without_assessments, :show
            def show
              @assessments = @issue.assessments
              @sla_events = @issue.sla_events
              show_without_assessments
            end
          end
        end
      end
    end
  end
  
IssuesController.send(:include, RedmineGercont::Patches::IssuesControllerPatch)

  