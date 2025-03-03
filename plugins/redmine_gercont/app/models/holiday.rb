class Holiday < ActiveRecord::Base
    self.table_name = 'contract_holidays'

    belongs_to :contract
    
end
