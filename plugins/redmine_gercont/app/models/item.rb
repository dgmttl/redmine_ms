class Item < ActiveRecord::Base
    self.table_name = 'contract_items'

    belongs_to :contract
    has_many :work_plan_items
    has_many :work_plans, through: :work_plan_items
    has_many :contract_members

    
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
    validates :profile, presence: true, uniqueness: true
    validates :shared_by, presence: true
    validates :unit_measure, presence: true
    validates :unit_value, presence: true

    before_save :format_currency

    PROFILES = [
      'product owner',
      'senior architect',
      'mid-level developer',
      'senior developer',
      'tech lead',
      'mid-level business/requirements analyst',
      'senior business/requirements analyst',
      'senior business intelligence analyst',
      'senior data admin',
      'scrum master',
      'requester',
    ].freeze

    def self.profile_options
        profiles = PROFILES.map { |profile| [I18n.t("profiles.#{profile}"), profile] }
        busy = Item.pluck(:profile)

        available = profiles.reject { |_, profile| busy.include?(profile) }
        
        available
    end

    def daily_cost
        (unit_value / 30).round(2)
    end

    private
    def format_currency
        self.unit_value = unit_value.to_s.tr(",", ".").to_f if unit_value.present?
    end

end
