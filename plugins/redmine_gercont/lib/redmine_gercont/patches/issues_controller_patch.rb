module RedmineGercont
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do

          helper :work_plans
          alias_method :original_new, :new
          alias_method :original_show, :show

          def new
            if @issue.contracts_any?
              parent_issue_id = params.dig(:issue, :parent_issue_id)

              if parent_issue_id.present?
                puts "Parent Issue ID: #{parent_issue_id}"
                parent =  Issue.find(parent_issue_id)
                if parent.demand?
                  @issue.tracker = Tracker.story
                elsif parent.story?
                  @issue.tracker = Tracker.task
                end
                @issue.parent = parent
                puts "===================@issue: #{@issue.inspect}"
              end
            end
            original_new
          end

          def show
            if @project.contracts.any?
              @assessments = @issue&.assessments || []
              @sla_events = @issue&.sla_events || []

              @work_plan = @issue&.work_plan
              @work_plan = @work_plan.load_baseline if @work_plan&.baseline.present?

              @sprints_objects = @work_plan&.sprints_objects
              @work_plan_items = @work_plan&.work_plan_items || []


              @work_plan_item = WorkPlanItem.new
              @work_order = @issue&.work_order
              @work_order_professionals = @issue.work_order_professionals ||= []
              
            end
            original_show
          end

          alias_method :original_bulk_edit, :bulk_edit
          def bulk_edit
            original_bulk_edit
            if @project.contracts.any?
              @versions = @project.versions.planning + @project.versions.rejected
            end
          end
        end
      end
    end
  end
end
  
IssuesController.send(:include, RedmineGercont::Patches::IssuesControllerPatch)

  