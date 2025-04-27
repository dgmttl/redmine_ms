class WorkPlansController < ApplicationController

    include WorkPlansHelper

    before_action :authorize_global
    before_action :find_project, only: [:index, :new, :create]
    before_action :find_work_plan, only: [:edit, :show, :update, :destroy, :add_item, :ask_for_work_plan_approval, :approve_work_plan, :reject_work_plan]
    before_action :find_work_plan_by_issue, only: [:save_release_plan]
    before_action :find_project_by_work_plan, only: [:edit, :update]
 
  
    def index
        @work_plans = @project&.work_plans || WorkPlan.all
    end

    def show
    end
  
    def new
        @work_plan = WorkPlan.new
    end
     
    def create
      @work_plan = WorkPlan.new(work_plan_params)
      if @work_plan.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to project_work_plans_path(@project)
      else
        render :new
      end
    end

    def edit
    end

    def update
      # @work_plan.baseline = work_plan_item_params[:status] == 'approved' ? @work_plan.generate_baseline : ''
      if @work_plan.update(work_plan_params)
        flash[:notice] = l(:notice_successful_update)
        # Redireciona de volta para onde foi chamado ou para um fallback
        redirect_back fallback_location: work_plans_path
      else
        render :edit
      end
    end



    def destroy
        @work_plan.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to @project.present? ? project_work_plan_path(@project) : work_plans_path
    end

     
    
    def save_release_plan        
      require 'json'
      
      sprints = params[:sprints].map { |sprint| JSON.parse(sprint, symbolize_names: true) }
      
      if sprints.any? { |sprint| sprint[:pbis].any? { |pbi| pbi[:fixed_version_id].nil? } }
        flash[:error] = l(:error_can_t_save_release_plan)
        product_backlog_path(@work_plan.issue.demand_backlog)
      else        
        sprint_data = sprints.each_with_index.map do |sprint, index|
          {
            index: index + 1,
            pbis: sprint[:pbis].map { |pbi| pbi[:id] },
            versions: sprint[:pbis].map { |pbi| pbi[:fixed_version_id] }.uniq,
            days: Setting.plugin_scrum['default_sprint_days'].to_i * (index + 1)
          }
        end

        if @work_plan.update(sprints: sprint_data.to_json)
          flash[:notice] = l(:notice_successful_update)
          redirect_to issue_work_plan_path
        else
          render :edit
        end
      end

    end

    def ask_for_work_plan_approval
      if @work_plan.update(status: 'planned')
        flash[:notice] = l(:notice_successful_update)
        redirect_to issue_work_plan_path
      else
        render :edit
      end
    end

    def approve_work_plan
      if @work_plan.update(status: 'approved')
        flash[:notice] = l(:notice_successful_update)
        redirect_to issue_work_plan_path
      else
        render :edit
      end
    end

    def reject_work_plan
      if @work_plan.update(status: 'rejected')
        flash[:notice] = l(:notice_successful_update)
        redirect_to issue_work_plan_path
      else
        render :edit
      end
    end
          
  
  private

  def find_project_by_work_plan
      @project = @work_plan.project
  end

  def find_project
      if params[:project_id]
        @project = Project.find(params[:project_id])
      end
  end

  def find_work_plan 
      @work_plan = WorkPlan.find(params[:id])
      if @work_plan&.baseline.present?
        baseline_data = @work_plan.load_baseline
        @work_plan = baseline_data[:work_plan]
        @sprints_objects = baseline_data[:sprints_objects]
        @work_plan_items = baseline_data[:work_plan_items]
      else
        @sprints_objects = @work_plan&.sprints_objects
        @work_plan_items = @work_plan&.work_plan_items || []
      end
      @issue = @work_plan&.issue
  end

  def find_work_plan_by_issue
    @issue = Issue.find(params[:id])

    @work_plan = @issue&.work_plan
    if @work_plan&.baseline.present?
      baseline_data = @work_plan.load_baseline
      @work_plan = baseline_data[:work_plan]
      @sprints_objects = baseline_data[:sprints_objects]
      @work_plan_items = baseline_data[:work_plan_items]
    else
      @sprints_objects = @work_plan&.sprints_objects
      @work_plan_items = @work_plan&.work_plan_items || []
    end
  end

  def work_plan_params
    params.require(:work_plan).permit(
      :issue_id,
      :status,
      :days_allocation
    )
  end

  def work_plan_item_params
    params.require(:work_plan_item).permit(
        :item_id,
        :quantity,
        :percentage,
        :rationale,
        sprints: []        
    )
  end
end
