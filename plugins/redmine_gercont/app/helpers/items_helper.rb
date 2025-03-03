module ItemsHelper
    
    def item_title(item)
        items = []
        items << [l(:label_contracts), contracts_path]
        items << [l(:label_catalog), contract_catalog_path] if item
        items << (item.nil? || item.new_record? ? l(:label_new_catalog_item) : item.name)
    
        title(*items)
    end

    def contract_catalog_path
      edit_contract_path(@item.contract, :tab => 'catalog')
    end
end
