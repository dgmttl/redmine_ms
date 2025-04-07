class ContractMembersController < ApplicationController

  include ContractMembersHelper

  before_action :authorize_global
  before_action :find_contract, only: [:index, :new, :create]
  before_action :find_contract_member, only: [:edit, :update, :destroy]

  def index
    @contract_members = @contract.contract_members.order(:date)
  end

  def new
    @contract_member = @contract.contract_members.new
  end

  def create
    @contract_member = @contract.contract_members.new(contract_member_params)
    create_contract_members_in_projects
    if @contract_member.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to contract_contract_member_path(@contract_member)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @contract = @contract_member.contract
    if @contract_member.update(contract_member_params)
      update_contract_members_in_projects
      flash[:notice] = l(:notice_successful_update)
      redirect_to contract_contract_member_path(@contract_member)
    else
      render :edit
    end
  end

  def destroy
    @contract = @contract_member.contract
    destroy_contract_members_in_projects
    @contract_member.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contract_contract_member_path(@contract_member)
  end

  private

  def find_contract
    @contract = Contract.find(params[:contract_id])
  end

  def find_contract_member
    @contract_member = ContractMember.find(params[:id])
  end

  def update_contract_members_in_projects
    @contract.projects.each do |project|
      member = project.members.find_by(user_id: @contract_member.user_id)
      if member
        member.role_ids = @contract_member.role_ids
        member.save!
      end
    end
  end
  
  

  def destroy_contract_members_in_projects
    return if @contract_member.profile != 'contract member'  
    Member.where(user_id: @contract_member.user_id, project_id: @contract.projects.pluck(:id)).destroy_all
  end
  
  
  def create_contract_members_in_projects
    project_ids = @contract.projects.pluck(:id) 
    Member.create_principal_memberships(
      @contract_member.user,
      project_ids: project_ids,
      role_ids: @contract_member.role_ids
    )
  end
  
  
  def contract_member_params
    params[:contract_member].permit(:user_id, :item_id, role_ids: [])
  end

end
