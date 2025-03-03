class ContractMember < ApplicationRecord
    belongs_to :contract
    belongs_to :user
    has_many :contract_member_roles, dependent: :destroy
    has_many :roles, through: :contract_member_roles
  
    validates :user_id, uniqueness: { scope: :contract_id}


    PROFILES = [
      ['product_owner', [100]],
      ['senior architect', [33, 66, 100]],
      ['mid-level developer', [100]],
      ['senior developer', [100]],
      ['tech lead', [33, 66, 100]],
      ['mid-level business analyst', [50, 100]], 
      ['mid-level requirements analyst', [50, 100]],
      ['senior business analyst', [33, 66, 100]],
      ['senior requirements analyst', [50, 100]],
      ['senior business intelligence analyst', [50, 100]],
      ['senior data admin', [20, 40, 60, 80, 100]],
      ['scrum master', [33, 66, 100]]
    ].freeze

    def self.profile_options
      PROFILES.map { |profile, perc_options| [I18n.t("profiles.#{profile}"), profile] }
    end

    def self.profile_perc_options
      PROFILES.map { |profile, perc_options| [I18n.t("profiles.#{profile}"), profile, perc_options] }
    end


  end
  