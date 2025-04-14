class Contract < ActiveRecord::Base

    has_and_belongs_to_many :projects
    has_and_belongs_to_many :trackers
    
    has_many :items, dependent: :destroy
    has_many :slas, dependent: :destroy
    has_many :rules, dependent: :destroy
    has_many :holidays, dependent: :destroy
    has_many :contract_members, dependent: :destroy
    # has_many :work_orders, through: :issue, dependent: :destroy
    # has_many :work_plans, through: :issue, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validate :terms_end_greater_than_terms_start

        
    STATUSES = ['new', 'active', 'closed', 'canceled'].freeze

    MODULES = ['issue_tracking', 'time_tracking', 'repository', 'redmine_gercont', 'scrum'].freeze

    def self.status_options
        STATUSES.map { |status| [I18n.t("statuses.contract.#{status}"), status] }
    end


    def agent
        contract_members.find { |member| member.role_ids.include?(Setting.plugin_redmine_gercont['role_for_agent'].to_i) }
    end

    def manager
        contract_members.find { |member| member.role_ids.include?(Setting.plugin_redmine_gercont['role_for_contract_manager'].to_i) }
    end


    private

    def terms_end_greater_than_terms_start
        if terms_end.present? && terms_start.present? && terms_end < terms_start + 3.months
            errors.add(:terms_end, l(:error_terms_end_date)) 
        end
    end
end

