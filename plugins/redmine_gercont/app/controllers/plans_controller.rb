class PlansController < ApplicationController

  before_action :authorize_global
  before_action :find_project, only: [:index, :new, :create]
  before_action :find_plan, only: [:edit, :update, :destroy]
  before_action :find_project_by_plan, only: [:edit, :update]

  
  
  def index
      @plans = @project&.plans || Plan.all
  end
  
  def new
     @plan = Plan.new
  end
     
  def create
      @plan = Plan.new(plan_params)
          if @plan.save
          flash[:notice] = l(:notice_successful_create)
          redirect_to project_plans_path(@project)
      else
          render :new
      end
  end

  def edit
  end

  def update
      if @plan.update(plan_params)
          flash[:notice] = l(:notice_successful_update)
          redirect_to plans_path
      else
          render :edit
      end
  end

  def destroy
      @plan.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to @project.present? ? project_plan_path(@project) : plans_path
  end

  def update_by_issue
      @issue = Issue.find(params[:issue_id])
      @plans = @issue.plans 
      if update_plans 
          flash[:notice] = l(:notice_successful_update) 
          redirect_to issue_path(@issue, :tab => 'plans') 
      else 
          render :edit
      end
  end
     
  
  private

  def update_plans
      params[:issue][:plans].each do |id, attributes|
          plan = Plan.find(id)
          unless plan.update(attributes.permit(:attendance, :technical_expertise, :conduct))
              return false 
          end 
      end 
      true
  end

  def find_project_by_plan
      @project = @plan.project
  end

  def find_project
      if params[:project_id]
        @project = Project.find(params[:project_id])
      end
  end

  def find_plan 
      @plan = Plan.find(params[:id])
  end

  def plan_params
      params.require(:plan).permit(
        :issue_id
      )
  end

end
