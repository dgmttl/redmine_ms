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
      

    # def self.percentage_options
    #     return [] if shared_by.nil? || shared_by <= 0

    #     step = 100.0 / shared_by
    #     (1..shared_by).map { |i| "#{(step * i).round}%" }
    # end

    def daily_cost
        (unit_value / 30).round(2)
    end

end
