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

end
