class WorkOrdersController < ApplicationController

  before_action :authorize_global
  before_action :find_project, only: [:index, :new, :create]
  before_action :find_work_order, only: [:edit, :update, :destroy]
  before_action :find_project_by_work_order, only: [:edit, :update]

  
  
  def index
      @work_orders = @project&.work_orders || WorkOrder.all
      logger.info "+++++++++++++++++++++ find_project - @project: #{@project.inspect}"
  end
  
  def new
     @work_order = WorkOrder.new
  end
     
  def create
      @work_order = WorkOrder.new(work_order_params)
          if @work_order.save
          flash[:notice] = l(:notice_successful_create)
          redirect_to project_work_orders_path(@project)
      else
          render :new
      end
  end

  def edit
  end

  def update
      if @work_order.update(work_order_params)
          flash[:notice] = l(:notice_successful_update)
          redirect_to work_orders_path
      else
          render :edit
      end
  end

  def destroy
      @work_order.destroy
      flash[:notice] = l(:notice_successful_delete)
      redirect_to @project.present? ? project_work_order_path(@project) : work_orders_path
  end

  def update_by_issue
      @issue = Issue.find(params[:issue_id])
      @work_orders = @issue.work_orders 
      if update_work_orders 
          flash[:notice] = l(:notice_successful_update) 
          redirect_to issue_path(@issue, :tab => 'work_orders') 
      else 
          render :edit
      end
  end
     
  
  private

  def update_work_orders
      params[:issue][:work_orders].each do |id, attributes|
          work_order = WorkOrder.find(id)
          unless work_order.update(attributes.permit(:issue_id))
              return false 
          end 
      end 
      true
  end

  def find_project_by_work_order
      @project = @work_order.project
  end

  def find_project
      if params[:project_id]
        @project = Project.find(params[:project_id])
      end
  end

  def find_work_order 
      @work_order = WorkOrder.find(params[:id])
  end

  def work_work_order_params
      params.require(:work_order).permit(
        :issue_id
      )
  end

end
