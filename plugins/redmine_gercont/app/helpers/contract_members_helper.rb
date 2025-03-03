module ContractMembersHelper

    def contract_member_title(contract_member)
        items = []
        items << [l(:label_contracts), contracts_path]
        items << [l(:label_contract_members), contract_contract_member_path] if contract_member
        items << (contract_member.nil? || contract_member.new_record? ? l(:label_new_contract_member) : contract_member.user.name)
    
        title(*items)
    end

    def contract_contract_member_path
        edit_contract_path(@contract_member.contract, :tab => 'member')
    end

    def member_options
        User.where(status: 1, admin: false).map { |user| [user.name, user.id] }
    end      

    def role_options
        roles = []
        
        cm_id = Setting.plugin_redmine_gercont["role_for_contract_manager"].to_i
        ti_id = Setting.plugin_redmine_gercont["role_for_technical_inspector"].to_i
        ai_id = Setting.plugin_redmine_gercont["role_for_administrative_inspector"].to_i
        ag_id = Setting.plugin_redmine_gercont["role_for_agent"].to_i
      
        roles << Role.find(cm_id)
        roles << Role.find(ti_id)
        roles << Role.find(ai_id)
        roles << Role.find(ag_id)
        
        roles
    end
      
      
end
