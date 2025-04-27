module RedmineGercont
  module Patches
    module RolePatch
      def self.included(base)
        base.class_eval do
          
          def self.contract_admin
            find(Setting.plugin_redmine_gercont["role_for_contract_admin"].to_i)
          end

          def self.contract_manager
            find(Setting.plugin_redmine_gercont["role_for_contract_manager"].to_i)
          end

          def self.technical_inspector
            find(Setting.plugin_redmine_gercont["role_for_technical_inspector"].to_i)
          end

          def self.administrative_inspector
            find(Setting.plugin_redmine_gercont["role_for_administrative_inspector"].to_i)
          end

          def self.requester
            find(Setting.plugin_redmine_gercont["role_for_requester"].to_i)
          end

          def self.agent
            find(Setting.plugin_redmine_gercont["role_for_agent"].to_i)
          end

          def self.product_owner
            find(Setting.plugin_redmine_gercont["role_for_product_owner"].to_i)
          end

          def self.scrum_master
            find_by(name: I18n.t(:default_role_scrum_master))
          end

          def self.scrum_team
            find_by(name: I18n.t(:default_role_scrum_team))
          end

        end
      end
    end
  end
end

Role.send(:include, RedmineGercont::Patches::RolePatch)