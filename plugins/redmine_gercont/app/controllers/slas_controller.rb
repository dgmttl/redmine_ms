class SlasController < CustomWorkflowsController
  include SlasHelper

  before_action :authorize_global
  before_action :find_contract, only: [:index, :new, :create]
  before_action :find_sla, only: [:edit, :update, :destroy]
  before_action :find_workflow, only: [:reorder, :change_status]
  before_action :find_contract_and_sla_by_workflow_id, only: [:reorder, :change_status]


  def reorder
    super
    redirect_to contract_sla_path
  end

  def change_status
    if @workflow.update(active: params[:active])
      flash[:notice] = l(:notice_successful_status_change)
      redirect_to contract_sla_path
    else
      render :edit
    end
  end

  def index
    @slas = @contract.slas
  end

  def new
    @sla = @contract.slas.new
  end

  def create
    @sla = @contract.slas.new(sla_params)
    @sla.custom_workflow = workflow_create

    manage_project_modules

    ActiveRecord::Base.transaction do
      if @sla.save        
        flash[:notice] = l(:notice_successful_create)
        redirect_to contract_sla_path
      else
        raise ActiveRecord::Rollback
        render :new
      end
    end
  end

  def edit
  end

  def update
    @sla.custom_workflow = CustomWorkflow.find(@sla.custom_workflow_id)
    workflow_data = {
                      name: sla_params[:acronym], 
                      active: sla_params[:assessments] == '1' ? false : true,
                      before_save: params[:custom_workflow][:before_save]
                    }

    manage_project_modules

    ActiveRecord::Base.transaction do
      if @sla.custom_workflow.update(workflow_data) && @sla.update(sla_params)
        flash[:notice] = l(:notice_successful_update)
        redirect_to contract_sla_path
      else
        raise ActiveRecord::Rollback
        render :edit
      end
    end
  end

  def destroy
    @sla.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contract_sla_path
  end


  private
  
  def find_workflow
    @workflow = CustomWorkflow.find(params[:id])
  end

  def find_contract_and_sla_by_workflow_id
    @sla = Sla.find_by(custom_workflow_id: @workflow.id)
    @contract = @rule.contract if @rule
  end

  def find_contract
    @contract = Contract.find(params[:contract_id])
  end

  def find_sla
    @sla = Sla.find(params[:id])
    # @sla.custom_workflow = CustomWorkflow.find(@sla.custom_workflow_id)
  end

  def manage_project_modules
    if @sla.contract.projects.any?
      @sla.contract.projects.each do |project|
        project.enable_module!(:slas)
        project.enable_module!(:assessments) if sla_params[:assessments] == '1'
      end
    end
  end

  def workflow_before_save_code
    "'your code goes here.'"
  end
  
  def workflow_contract_name
    "#{@sla.contract.name}_#{l(:label_sla_short)}_#{@sla.acronym}"
  end

  def workflow_create
    CustomWorkflow.create!(
      name: workflow_contract_name,
      before_save: workflow_before_save_code,
      description: "",
      string: "",
      position: CustomWorkflow.count + 1,
      integer: 1,
      is_for_all: false,
      active: !@sla.assessments,
      observable: "issue",
      project_ids: @sla.contract.project_ids
    )
  end

  def sla_params
    params[:sla].permit(:name, :description, :acronym, :frequency, :target, :assessments)
  end
end

