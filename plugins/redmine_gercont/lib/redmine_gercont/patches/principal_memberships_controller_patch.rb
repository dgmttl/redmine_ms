module RedmineGercont
  module Patches
    module PrincipalMembershipsControllerPatch
      def self.included(base)
        base.class_eval do

          include AssessmentsHelper

          alias_method :original_create, :create
          def create
            original_create

            projects = Project.joins(:contracts)
              .where(contracts: { status: ['active', 'new'] })
              .where(id: params[:membership][:project_ids])
              .distinct

            projects.each do |project|
              project.contracts.each do |contract|
                ContractMember.create(
                  contract_id: contract.id,
                  user_id: params[:user_id],
                  role_ids: params[:membership][:role_ids]
                )
              end
            end
          end

          alias_method :original_update, :update
          def update
            original_update
            contract_member = ContractMember.find_by_user_id(@membership.user.id)
            contract_member.role_ids = params[:membership][:role_ids]
            contract_member.save
          end

        end
      end
    end
  end
end
  
PrincipalMembershipsController.send(:include, RedmineGercont::Patches::PrincipalMembershipsControllerPatch)

  