class WorkPlansController < ApplicationController

  before_action :authorize_global
  before_action :find_project, only: [:index, :new, :create]
  before_action :find_work_plan, only: [:edit, :update, :destroy]
  before_action :find_project_by_work_plan, only: [:edit, :update]

  
  
  def index
      @work_plans = @project&.work_plans || WorkPlan.all
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
      if @work_plan.update(work_plan_params)
          flash[:notice] = l(:notice_successful_update)
          redirect_to work_plans_path
      else
          render :edit
      end
  end

  def destroy
      @work_plan.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to @project.present? ? project_work_plan_path(@project) : work_plans_path
  end

  def update_by_issue
      @issue = Issue.find(params[:issue_id])
      @work_plans = @issue.work_plans 
      if update_work_plans 
          flash[:notice] = l(:notice_successful_update) 
          redirect_to issue_path(@issue, :tab => 'work_plans') 
      else 
          render :edit
      end
  end
     
  
  private

  def update_work_plans
      params[:issue][:work_plans].each do |id, attributes|
          work_plan = WorkPlan.find(id)
          unless work_plan.update(attributes.permit(:issue_id))
              return false 
          end 
      end 
      true
  end

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
  end

  def work_work_plan_params
      params.require(:work_plan).permit(
        :issue_id
      )
  end

end
