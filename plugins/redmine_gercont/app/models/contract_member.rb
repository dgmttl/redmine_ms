class ContractMember < ApplicationRecord

    belongs_to :contract
    belongs_to :user
    belongs_to :item
    has_many :contract_member_roles, dependent: :destroy
    has_many :roles, through: :contract_member_roles
      
    validates :user_id, uniqueness: { scope: :contract_id}


    def member_options
      User.where(status: 1, admin: false).map { |user| [user.name, user.id] }
    end

    def self.role_options
      roles = []
    
      # IDs de configuração
      cm_id = Setting.plugin_redmine_gercont["role_for_contract_manager"].to_i
      ti_id = Setting.plugin_redmine_gercont["role_for_technical_inspector"].to_i
      ai_id = Setting.plugin_redmine_gercont["role_for_administrative_inspector"].to_i
      ag_id = Setting.plugin_redmine_gercont["role_for_agent"].to_i
      ca_id = Setting.plugin_redmine_gercont["role_for_contract_admin"].to_i
    
      # Certifique-se de que os IDs existem e são válidos
      [cm_id, ti_id, ai_id, ag_id, ca_id].each do |id|
        role = Role.find_by(id: id)
        roles << role if role
      end
    
      roles
    end
    

  def contract_members_role_ids
      ContractMember.role_options.map(&:id)
  end

  def profile

    if ContractMember.role_options.map(&:id).any? { |role_id| roles.map(&:id).include?(role_id) }
      'contract member'
    else
      item&.profile
    end
  end

  end
  