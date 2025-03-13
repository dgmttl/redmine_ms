module RedmineGercont
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do
          
          helper ScrumHelper

          alias_method :original_show, :show
          def show
            if @project.contracts.any?
              @assessments = @issue.assessments
              @sla_events = @issue.sla_events
              @work_plan = @issue.work_plan
              @work_order = @issue.work_order
              @work_order_professionals = @issue.work_order_professionals ||= []
              @product_backlog = @issue.product_backlog
              @pbi_filter = {}

              #variables for release plan
              @sprints = []
              velocity_all_pbis, velocity_scheduled_pbis, @sprints_count = @project.story_points_per_sprint(@pbi_filter)
              @velocity_type = params[:velocity_type] || 'custom'
              case @velocity_type
                when 'all'
                  @velocity = velocity_all_pbis
                when 'only_scheduled'
                  @velocity = velocity_scheduled_pbis
                else
                  @velocity = (params[:custom_velocity].to_f unless params[:custom_velocity].blank?) || Setting.plugin_scrum['product_backlog_default_velocity'].to_f
              end
              @velocity = 1.0 if @velocity.blank? or @velocity < 1.0
              @total_story_points = 0.0
              @pbis_with_estimation = 0
              @pbis_without_estimation = 0
              versions = {}
              accumulated_story_points = @velocity
              current_sprint = {:pbis => [], :story_points => 0.0, :versions => []}
              @product_backlog.pbis(@pbi_filter).each do |pbi|
                if pbi.story_points
                  @pbis_with_estimation += 1
                  story_points = pbi.story_points.to_f
                  @total_story_points += story_points
                  while accumulated_story_points < story_points
                    @sprints << current_sprint
                    accumulated_story_points += @velocity
                    current_sprint = {:pbis => [], :story_points => 0.0, :versions => []}
                  end
                  accumulated_story_points -= story_points
                  current_sprint[:pbis] << pbi
                  current_sprint[:story_points] += story_points
                  if pbi.fixed_version
                    versions[pbi.fixed_version.id] = {:version => pbi.fixed_version,
                                                      :sprint => @sprints.count}
                  end
                else
                  @pbis_without_estimation += 1
                end
              end
              if current_sprint and (current_sprint[:pbis].count > 0)
                @sprints << current_sprint
              end
              versions.values.each do |info|
                @sprints[info[:sprint]][:versions] << info[:version]
              end
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

  