module RedmineGercont
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          has_many :sla_events, through: :issues, dependent: :destroy
          has_many :assessments, through: :sla_events, dependent: :destroy
          has_many :work_orders, through: :issues, dependent: :destroy
          has_many :work_plans, through: :issues, dependent: :destroy
          has_many :work_order_professionals, through: :work_plans, dependent: :destroy
          has_and_belongs_to_many :contracts


          def active_contracts
            contracts.select { |contract| contract.status == 'active' } if contracts.present?
          end

          def contract
            active_contracts&.first
          end
          
        end
      end
    end
  end
end

Project.send(:include, RedmineGercont::Patches::ProjectPatch)