module ContractsHelper

    def contract_editing_tabs
        tabs = [
                {:name => 'info',
                 :action => :manage_contract,
                 :partial => 'contracts/form',
                 :label =>  :label_contract
                },
                {:name => 'member',
                 :action => :manage_contract,
                 :partial => 'contract_members/index', 
                 :label =>  :label_member_plural
                },
                {:name => 'catalog',
                 :action => :manage_contract,
                 :partial => 'items/index', 
                 :label =>  :label_catalog
                },
                {:name => 'sla',
                :action => :manage_contract,
                :partial => 'slas/index', 
                :label =>  :label_slas
               },
               {:name => 'rule',
                :action => :manage_contract,
                :partial => 'rules/index', 
                :label =>  :label_rules
               }, 
               {:name => 'holiday',
               :action => :manage_contract,
               :partial => 'holidays/index', 
               :label =>  :label_holidays
              }
        ]
    end

    def sum_active_contracts(contracts)
        contracts.select { |contract| contract.status == 'active' }.count
    end

    def sum_closed_contracts(contracts)
        contracts.select { |contract| contract.status == 'closed' }.count
    end

    def sum_canceled_contracts(contracts)
        contracts.select { |contract| contract.status == 'canceled' }.count
    end

    def sum_itens_contract(items)
        items.size
    end

    def med_valor_itens_contract(items)
        items.size > 0 ? (items.sum(&:unit_value) / items.size).round(2) : 0
    end

    def sum_slas_contract(slas) 
        slas.size
    end

    def role_options
        roles = []
        
        cm_id = Setting.plugin_redmine_gercont["role_for_contract_manager"].to_i
        ti_id = Setting.plugin_redmine_gercont["role_for_technical_inspector"].to_i
        ti_id = Setting.plugin_redmine_gercont["role_for_technical_inspector"].to_i
        ai_id = Setting.plugin_redmine_gercont["role_for_administrative_inspector"].to_i
        ag_id = Setting.plugin_redmine_gercont["role_for_agent"].to_i
        ca_id = Setting.plugin_redmine_gercont["role_for_contract_admin"].to_i
      
        roles << Role.find(cm_id)
        roles << Role.find(ti_id)
        roles << Role.find(ai_id)
        roles << Role.find(ag_id)
        roles << Role.find(ca_id)
        
        roles
    end

    def contract_members_role_ids
        role_options.map(&:id)
    end
    
end