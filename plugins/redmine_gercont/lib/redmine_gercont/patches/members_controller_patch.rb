module RedmineGercont
  module Patches
    module MembersControllerPatch
      def self.included(base)
        base.class_eval do

          # include AssessmentsHelper

          alias_method :original_create, :create
          def create
            original_create

            project = params[:project_id]
            contracts = Project.find(project).contracts.where(status: ['new', 'active'])
            users_ids = params[:membership][:user_ids]

            contracts.each do |contract|
              users_ids.each do |user_id|
                ContractMember.create(
                  contract_id: contract.id,
                  user_id: user_id,
                  role_ids: params[:membership][:role_ids]
                ) unless contract.contract_members.where(user_id: user_id).present?
              end
            end
          end
          
          
          alias_method :original_update, :update
          def update

            new_role_ids = params[:membership][:role_ids].map(&:to_i).reject { |id| id == 0 }
            role_for_contract_admin = Setting.plugin_redmine_gercont['role_for_contract_admin'].to_i

            if @project.identifier == l(:default_project_name).downcase.gsub(" ", "_") &&
              User.current.id == @member.user_id &&
              !new_role_ids.include?(role_for_contract_admin)

                new_role_ids << role_for_contract_admin
              params[:membership][:role_ids] = new_role_ids.map(&:to_s)
              original_update
            else
              original_update
              contract_member = ContractMember.find_by_user_id(@member.user_id)
              if contract_member.present?
                contract_member.role_ids = params[:membership][:role_ids]
                contract_member.save!
              end
            end
          end

          alias_method :original_destroy, :destroy
          def destroy
            new_role_ids = params[:membership][:role_ids].map(&:to_i).reject { |id| id == 0 }
            role_for_contract_admin = Setting.plugin_redmine_gercont['role_for_contract_admin'].to_i

            if @project.identifier == l(:default_project_name).downcase.gsub(" ", "_") &&
              User.current.id == @member.user_id

              flash[:warning] = l(:error_can_not_remove_role)
            
            else
              original_destroy
            end
          end
        end
      end
    end
  end
end
  
MembersController.send(:include, RedmineGercont::Patches::MembersControllerPatch)

  