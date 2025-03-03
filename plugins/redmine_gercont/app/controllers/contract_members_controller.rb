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
      redirect_to contract_contract_member_path
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
      redirect_to contract_contract_member_path
    else
      render :edit
    end
  end

  def destroy
    @contract = @contract_member.contract
    destroy_contract_members_in_projects
    @contract_member.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to contract_contract_member_path
  end

  private

  def find_contract
    @contract = Contract.find(params[:contract_id])
  end

  def find_contract_member
    @contract_member = ContractMember.find(params[:id])
  end

  def update_contract_members_in_projects
    if @contract.projects.any?
      @contract.projects.each do |project|
        member = Member.find_by_user_id(@contract_member.user_id)
        member.role_ids = @contract_member.role_ids
        member.save!
      end
    end  
  end

  def destroy_contract_members_in_projects
    if @contract.projects.any?
      @contract.projects.each do |project|
        if project.members.any? { |member| member.user_id == @contract_member.user_id }
          Member.find_by_user_id(@contract_member.user_id).destroy
        end
      end
    end  
  end
  
  def create_contract_members_in_projects
    if @contract.projects.any?
      @contract.projects.each do |project|
        Member.create_principal_memberships(
          @contract_member.user, 
          :project_ids => [project.id], 
          :role_ids => @contract_member.role_ids
        )
      end
    end
  end
  
  def contract_member_params
    params[:contract_member].permit(:user_id, :profile, role_ids: [])
  end

end
