module RulesHelper

    def tracker_options
        @rule.contract.trackers.map do |tracker|
            [tracker.name, tracker.id]
        end
    end

    def rule_title(rule)
        items = []
        items << [l(:label_contracts), contracts_path]
        items << [l(:label_rules), contract_rule_path] if rule
        items << (rule.nil? || rule.new_record? ? l(:label_new_rule) : rule.custom_workflow.name)
    
        title(*items)
    end

    def contract_rule_path
          edit_contract_path(@rule.contract, :tab => 'rule')
    end
end
