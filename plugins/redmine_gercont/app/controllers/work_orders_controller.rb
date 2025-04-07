class WorkOrdersController < ApplicationController

  before_action :authorize_global
  before_action :find_project, only: [:index, :new, :create]
  before_action :find_work_order, only: [:edit, :update, :destroy]
  before_action :find_project_by_work_order, only: [:edit, :update]
  before_action :find_issue, only: [:generate_work_order]

  
  
  def index
      @work_orders = @project&.work_orders || WorkOrder.all
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

    def generate_work_order
        
        # 1. generate work plan baseline
        @work_plan = @issue.work_plan
        @work_plan.generate_baseline

        logger.info "+++++++++++++++++++ Tamanho do JSON: #{@work_plan.baseline.bytesize} bytes"

        @work_plan.update(status: 'closed')
        baseline = @work_plan.load_baseline       

        # 2. create sprints
        create_sprints(baseline.sprints_objects)
       
       # 3. create work order
        @work_order = WorkOrder.new(work_order_params)
        @work_order.static_data = fill_static_data



    end

    def create_sprints(sprints_objects)
        start_date = Holiday.next_work_day
        
        sprints_objects.each do |object|
            sprint = Sprint.new(
                name: "#{l(:label_sprint)} #{object[:index]}",
                description: "[#{l(:label_view)} #{@issue.to_s.split(':')[0]}](/issues/#{@issue.id})",
                status: 'open',
                shared: '0',
                is_product_backlog: 'false',
                project: @issue.project,
                sprint_start_date: start_date,
                sprint_end_date: start_date + Holiday.calendar_days((Setting.plugin_scrum['default_sprint_days'].to_i - 1), start_date),
                user: User.current
            )
            sprint.save!

            object[:pbis].each do |pbi|
                logger.info " +++++++++++++++++++ sprint.id: - #{sprint.id}" 
                logger.info "+++++++++++++++++++++ start_date: - #{sprint.sprint_start_date}"
                logger.info "+++++++++++++++++++++ due_date: - #{sprint.sprint_end_date}"

                story = Issue.find(pbi[:id])

                    begin
                        story.update!(
                          sprint_id: sprint.id,
                          start_date: sprint.sprint_start_date,
                          due_date: sprint.sprint_end_date
                        )
                      rescue ActiveRecord::RecordNotUnique => e
                        Rails.logger.error "Erro de unicidade ao atualizar o PBI: #{story.id}"
                        Rails.logger.error e.message
                        raise
                      end
                logger.info " +++++++++++++++++++ PBI ATUALIZADO!"
            end

            object[:versions].each do |version|
                version.update(effective_date: sprint.sprint_end_date)
            end

            start_date = sprint.sprint_end_date + 1
        end
    end



#   def update_by_issue
#       @issue = Issue.find(params[:issue_id])
#       @work_orders = @issue.work_orders 
#       if update_work_orders 
#           flash[:notice] = l(:notice_successful_update) 
#           redirect_to issue_path(@issue, :tab => 'work_orders') 
#       else 
#           render :edit
#       end
#   end
     
  
  private

#   def update_work_orders
#       params[:issue][:work_orders].each do |id, attributes|
#           work_order = WorkOrder.find(id)
#           unless work_order.update(attributes.permit(:issue_id))
#               return false 
#           end 
#       end 
#       true
#   end

  def find_issue
    @issue = Issue.find(params[:issue_id])
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

  def work_order_params
      params.require(:work_order).permit(
        :issue_id,
        :status
      )
  end

end
