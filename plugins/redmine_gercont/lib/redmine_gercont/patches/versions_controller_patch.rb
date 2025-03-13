module RedmineGercont
    module Patches
      module VersionsControllerPatch
        def self.included(base)
          base.class_eval do
            
            skip_before_action :find_model_object, only: [:approve_plan, :ask_for_plan_approval]
            skip_before_action :find_project_from_association, only: [:approve_plan, :ask_for_plan_approval]
            skip_before_action :authorize, only: [:approve_plan, :ask_for_plan_approval]

            before_action :find_project, only: [:approve_plan, :ask_for_plan_approval]
            before_action :authorize, only: [:approve_plan, :ask_for_plan_approval]

            helper :issues

            def ask_for_plan_approval
              planning = @project.versions.planning + @project.versions.rejected
           
              if planning.any? { |version| version.issues_count == 0 }
                flash[:error] = l(:text_need_associate_stories_to_versions)
                redirect_to project_versions_path(@project)
              else
                planned_ids = planning.pluck(:id) # Obtém os IDs das versões planejadas
                Version.where(id: planned_ids).update_all(status: 'planned')
                redirect_to project_versions_path(@project)
              end
            end
            
            
            def approve_plan
              planned = @project.versions.for_approve_or_not.pluck(:id) 
              approved = params[:version_ids].map(&:to_i) & planned
              rejected = planned - approved

              if approved.present?
                Version.where(id: approved).update_all(status: 'approved')
                if rejected.present?
                  Version.where(id: rejected).update_all(status: 'rejected')
                end
                render json: { message: l(:notice_successful_update) }, status: :ok
                
              else
                render json: { message: l(:notice_select_at_least_one_version) }, status: :unprocessable_entity
              end
            end

            alias_method :original_create, :create
            def create
              if @project.contracts.any?
                params[:version][:status] ||= 'planning' if params[:version]
              end
              original_create
            end

            alias_method :original_index, :index
            def index
              original_index
              if @project.contracts.any?
                @versions = @project.versions
              end
            end
            

          end
        end
      end
    end
  end
  
VersionsController.send(:include, RedmineGercont::Patches::VersionsControllerPatch)

  