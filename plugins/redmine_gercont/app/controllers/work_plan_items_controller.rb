class WorkPlanItemsController < ApplicationController


    before_action :authorize_global
    before_action :find_work_plan, only: [:index, :new, :create]
    before_action :find_work_plan_item, only: [:destroy]

  
  
    def index
        @work_plan_items = @work_plans&.work_plan_items
    end
  
    def new
        @work_plan_item = @work_plan.work_plan_items.new
    end
     
    def create
      @work_plan_item = @work_plan.work_plan_items.new(work_plan_item_params)
      if @work_plan_item.save
          flash[:notice] = l(:notice_successful_create)
          redirect_to issue_path(@work_plan.issue, :tab => 'work_plan')
      else
          render :new
      end
    end

    def destroy
        @work_plan_item.destroy
        flash[:notice] = l(:notice_successful_delete)
        redirect_to issue_path(@work_plan_item.work_plan.issue, :tab => 'work_plan')
    end

          
  
    private

    def find_work_plan_item
      @work_plan_item = WorkPlanItem.find(params[:id])
    end

    def find_work_plan 
        @work_plan = WorkPlan.find(params[:work_plan_id])
    end

    def work_plan_item_params
      params.require(:work_plan_item).permit(
          :work_plan_id,
          :item_id,
          :quantity,
          :percentage,
          :rationale,
          sprints: []        
      )
    end

end
