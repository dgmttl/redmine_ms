class ContractsController < ApplicationController
  helper :trackers
  include ContractsHelper

  before_action :authorize_global
  before_action :find_contract, only: [:edit, :update, :destroy]
  before_action :find_projects, only: [:new, :create, :edit, :update]
  before_action :find_trackers, only: [:new, :create, :edit, :update]
  before_action :find_rules, only: [:new, :create, :edit, :update]
  before_action :find_holidays, only: [:new, :create, :edit, :update]
  before_action :find_contract_members, only: [:new, :create, :edit, :update]

  def index
    @contracts = Contract.all.order(:status)
  end

  def new
    @contract = Contract.new
  end

  def create
    @contract = Contract.new(contract_params)
    @added_projects = added_project_ids.present? ? Project.where(id: added_project_ids) : []
    if @contract.save
        manage_project_modules
        manage_project_trackers
        manage_project_pbl
        manage_custom_workflows
        create_project_members_in_contract
        manage_contract_members_in_project
      create_national_holidays(@contract.terms_start, @contract.terms_end)
      flash[:notice] = l(:notice_successful_create)
      redirect_to contracts_path
    else
      render :new
    end
  end

  def edit
    @items = @contract.items
    @slas = @contract.slas
    @rules = @contract.rules.includes(:custom_workflow).order('custom_workflows.position')
    @holidays = @contract.holidays.order(:date)
    @contract_members, @project_members = @contract.contract_members
      .select { |member| member.user && member.user.active? }
      .partition do |member|
        member.roles.any? { |role| ContractMember.role_options.include?(role) }
    end
  end

  def update
    @contract_was = @contract.dup

    @added_projects = added_project_ids.present? ? Project.where(id: added_project_ids) : []
    
    if contract_projects_changed?

      @contract.assign_attributes(contract_params)

      manage_contract_members_in_project
      manage_project_modules
      manage_project_trackers
      manage_project_pbl
      manage_custom_workflows
      create_project_members_in_contract

    end

    if @contract.update(contract_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to contracts_path
    else
      @items = @contract.items
      @slas = @contract.slas
      @rules = @contract.rules.includes(:custom_workflow).order('custom_workflows.position')
      @holidays = @contract.holidays.order(:date)
      @contract_members = @contract.contract_members
      render :edit
    end
  end

  def destroy    
    @contract.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contracts_path
  end

  def default_configuration
    if request.post?
      begin
        RedmineGercont::DefaultData::Loader::load(params[:lang])
        flash[:notice] = l(:notice_default_data_loaded)
      rescue => e
        flash[:error] = l(:error_can_t_load_default_data, ERB::Util.h(e.message))
      end
    end
    redirect_to contracts_path
  end

  private

  def create_national_holidays(start_date, end_date)
    holidays = Holidays.between(start_date, end_date, :br, :informal)
  
    holidays.each do |holiday|
      Holiday.create(description: holiday[:name], date: holiday[:date], contract_id: @contract.id)
    end
  end

  def find_contract_members
    @contract_members = ContractMember.all
  end
  
  def find_holidays
    @holidays = Holiday.all.order(:date)
  end

  def find_rules
    @rules = Rule.all.includes(:custom_workflow).order('custom_workflows.position')
  end

  def find_trackers
    @trackers = Tracker.all
  end

  def find_projects
    @projects = Project.all
  end

  def find_contract
    @contract = Contract.find(params[:id])
  end


  def manage_project_modules
    return unless @contract.projects.any?

    contract_modules = Contract::MODULES
    @contract.projects.each do |project|
      project.enabled_module_names = contract_modules

    end
  end
  

  def manage_project_trackers
    return if @added_projects.blank?

 
    tracker_ids = contract_params[:tracker_ids]
    return if tracker_ids.blank?
  
    @added_projects.each do |project|
      project.tracker_ids = tracker_ids
      project.save
    end
  end
  
  def manage_custom_workflows
    return if @added_projects.blank?
    
    workflows = CustomWorkflow.where(
      "name LIKE ? AND observable IN (?)", "GERCONT_%",
       CustomWorkflow::PROJECT_OBSERVABLES
    )

    @added_projects.each do |project|
      project.custom_workflow_ids = workflows.map(&:id)
      project.save!
    end
  end

  def manage_project_pbl
    return if @added_projects.blank?

    @added_projects.each do |project|
      next if project.product_backlogs.any?
  
      Sprint.find_or_create_by(
        user: User.current,
        project: project,
        is_product_backlog: true,
        name: l(:label_project_backlog),
        description: l(:text_created_automaticaly),
        status: 'open',
        shared: '0'
      )
    end
  end
  

  def create_project_members_in_contract
    return if @added_projects.blank?

    

    @added_projects.each do |project|
      project.members.each do |member|
        next if @contract.contract_members.map(&:user).include?(member.user)

        contract_roles = ContractMember.role_options
        contract_roles.delete_if { |role| role.name == l(:default_role_contract_admin) }
        member_roles = member.roles.reject { |role| contract_roles.include?(role) || role.blank? }.map(&:id)

        ContractMember.create(
          contract_id: @contract.id,
          user_id: member.user_id, 
          role_ids: member_roles
        ) unless member_roles.empty?
      end
    end
  end
  

  def contract_projects_changed?
    @contract_was.project_ids != contract_params[:project_ids].reject(&:empty?).map(&:to_i) ? true : false
  end

  def added_project_ids
    if @contract_was.present?
      contract_params[:project_ids].reject(&:empty?).map(&:to_i) - @contract_was.project_ids
    else
      contract_params[:project_ids].reject(&:empty?).map(&:to_i)
    end
  end

  def contract_members
    @contract.contract_members.select { |member| member.profile == 'contract member' }
  end

  # if project in: add contract_members to project member
  # if project out: retire contract_members from project_member
  def manage_contract_members_in_project
    if contract_members.any?
      if !added_project_ids.blank?
        contract_members.each do |member|
          Member.create_principal_memberships(
            member.user, 
            project_ids: added_project_ids, 
            role_ids: member.role_ids
          )
        end
      end
    end
  end

  def contract_params
    return {} unless params[:contract].present?
    params.require(:contract).permit(
      :name, 
      :terms_reference,
      :object_description,
      :user_id,
      :terms_start, 
      :terms_end, 
      :contractor, 
      :cnpj, 
      :status, 
      project_ids: [],
      tracker_ids: []
    )
  end

end
