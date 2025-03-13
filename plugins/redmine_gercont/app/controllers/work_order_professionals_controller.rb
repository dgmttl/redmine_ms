class WorkOrderProfessionalsController < ApplicationController

  before_action :authorize_global
  before_action :find_project, only: [:index, :new, :create]
  before_action :find_work_order_professional, only: [:edit, :update, :destroy]
  before_action :find_project_by_work_order_professional, only: [:edit, :update]

  
  
  def index
      @work_order_professionals = @project&.work_order_professionals || WorkOrderProfessional.all
  end
  
  def new
     @work_order_professional = WorkOrderProfessional.new
  end
     
  def create
      @work_order_professional = WorkOrderProfessional.new(work_order_professional_params)
          if @work_order_professional.save
          flash[:notice] = l(:notice_successful_create)
          redirect_to project_work_order_professionals_path(@project)
      else
          render :new
      end
  end

  def edit
  end

  def update
      if @work_order_professional.update(work_order_professional_params)
          flash[:notice] = l(:notice_successful_update)
          redirect_to work_order_professionals_path
      else
          render :edit
      end
  end

  def destroy
      @work_order_professional.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to @project.present? ? project_work_order_professional_path(@project) : work_order_professionals_path
  end

  def update_by_issue
      @issue = Issue.find(params[:issue_id])
      @work_order_professionals = @issue.work_order_professionals 
      if update_work_order_professionals 
          flash[:notice] = l(:notice_successful_update) 
          redirect_to issue_path(@issue, :tab => 'work_order_professionals') 
      else 
          render :edit
      end
  end
     
  
  private

  def update_work_order_professionals
      params[:issue][:work_order_professionals].each do |id, attributes|
          work_order_professional = WorkOrderProfessional.find(id)
          unless work_order_professional.update(attributes.permit(:issue_id))
              return false 
          end 
      end 
      true
  end

  def find_project_by_work_order_professional
      @project = @work_order_professional.project
  end

  def find_project
      if params[:project_id]
        @project = Project.find(params[:project_id])
      end
  end

  def find_work_order_professional 
      @work_order_professional = WorkOrderProfessional.find(params[:id])
  end

  def work_work_order_professional_params
      params.require(:work_order_professional).permit(
        :work_order_id
      )
  end

end
