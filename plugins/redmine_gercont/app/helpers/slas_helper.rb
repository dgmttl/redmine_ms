module SlasHelper
    
    def sla_title(sla)
        items = []
        items << [l(:label_contracts), contracts_path]
        items << [l(:label_slas), contract_sla_path] if sla
        items << (sla.nil? || sla.new_record? ? l(:label_new_sla) : sla.acronym)
    
        title(*items)
    end

    def contract_sla_path        
        edit_contract_path(@sla.contract, :tab => 'sla')
    end
end
