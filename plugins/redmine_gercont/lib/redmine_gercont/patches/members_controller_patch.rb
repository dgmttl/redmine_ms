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
            original_update
            contract_member = ContractMember.find_by_user_id(@member.user_id)

            contract_member.role_ids = params[:membership][:role_ids]
            contract_member.save!

          end
        end
      end
    end
  end
end
  
MembersController.send(:include, RedmineGercont::Patches::MembersControllerPatch)

  