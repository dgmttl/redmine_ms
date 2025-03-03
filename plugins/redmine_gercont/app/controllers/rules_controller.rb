class RulesController < CustomWorkflowsController
  include RulesHelper

  before_action :authorize_global
  before_action :find_contract, only: [:index, :new, :create]
  before_action :find_rule, only: [:edit, :update, :destroy]
  before_action :find_workflow, only: [:reorder, :change_status]
  before_action :find_contract_and_rule_by_workflow_id, only: [:reorder, :change_status]
  
  def reorder
    super
    respond_to do |format|
      format.html { redirect_to contract_rule_path }
      format.js   { render js: "window.location = '#{contract_rule_path}';" }
    end
  end
  

  def change_status
    if @workflow.update(active: params[:active])
      flash[:notice] = l(:notice_successful_status_change)
      redirect_to contract_rule_path
    else
      render :edit
    end
  end
    
  def index
    @rules = @contract.rules
  end

  def new
    @rule = @contract.rules.new
    @rule.custom_workflow = CustomWorkflow.new
  end

  def create
    ActiveRecord::Base.transaction do
      @rule = @contract.rules.new(rule_params)
      custom_workflow = workflow_create
      @rule.custom_workflow = custom_workflow
      
      if @rule.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to contract_rule_path
      else
        raise ActiveRecord::Rollback
        render :new
      end
    end
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      if @rule.custom_workflow.present?
        @rule.custom_workflow.update!(workflow_params)   
      end

      if @rule.update(rule_params)
        flash[:notice] = l(:notice_successful_update)
        redirect_to contract_rule_path
      else
        raise ActiveRecord::Rollback
        render :edit
      end
    end
  end
  

  def destroy
    @rule.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contract_rule_path
  end

  private

  def find_contract
    @contract = Contract.find(params[:contract_id])
  end
  
  def find_rule
    @rule = Rule.find(params[:id])
  end
  
  def find_workflow
    @workflow = CustomWorkflow.find(params[:id])
  end
  
  def workflow_create
    CustomWorkflow.create!(
      name: workflow_contract_name,
      before_save: workflow_params[:observable] != 'shared' ? workflow_before_save_code : "",
      shared_code: workflow_params[:observable] == 'shared' ? l(:text_code_local) : "",
      description: "",
      string: "",
      position: CustomWorkflow.count + 1,
      integer: 1,
      is_for_all: false,
      active: true,
      observable: workflow_params[:observable],
      project_ids: @rule.contract.project_ids
    )
  end

  def workflow_before_save_code
    if workflow_params[:observable] == 'issue'
      "if project.contracts.any? { |contract| contract.id == #{@rule.contract_id} } && tracker_id == #{@rule.tracker_id}\n\n\n ' #{l(:text_code_local)} '\n\n\nend\n"
    else
      " ' #{l(:text_code_local)} ' "
    end
  end

  def workflow_contract_name
    "#{@rule.contract.name}_#{@rule.action}_#{
      workflow_params[:observable] == 'issue' ? @rule.tracker.name : workflow_params[:observable]  
    }_#{workflow_params[:name]}"
  end
    
  def find_contract_and_rule_by_workflow_id
    @rule = Rule.find_by(custom_workflow_id: @workflow.id)
    @contract = @rule.contract if @rule
  end
  
  def workflow_params
    params.require(:custom_workflow).permit(:name, :observable, :before_save, :shared_code)
  end
  
  def rule_params
    params[:rule].permit(:action, :tracker_id)
  end
end
