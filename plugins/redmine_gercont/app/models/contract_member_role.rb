class ContractMemberRole < ApplicationRecord

    belongs_to :contract_member
    belongs_to :role
    
end
