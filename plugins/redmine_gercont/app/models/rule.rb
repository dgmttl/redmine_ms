class Rule < ApplicationRecord
    self.table_name = 'contract_rules'

    belongs_to :contract
    belongs_to :tracker
    belongs_to :custom_workflow, dependent: :destroy

    validates :contract_id, presence: true

    ACTION = ['automator','validator', 'shared_code' ].freeze

    def self.action_options
        ACTION.map { |action| [I18n.t("actions.#{action}"), action] }
    end

end
# 