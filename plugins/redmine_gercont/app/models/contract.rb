class Contract < ActiveRecord::Base

    has_and_belongs_to_many :projects
    has_and_belongs_to_many :trackers
    
    has_many :items, dependent: :destroy
    has_many :slas, dependent: :destroy
    has_many :rules, dependent: :destroy
    has_many :holidays, dependent: :destroy
    has_many :contract_members, dependent: :destroy
    has_many :work_orders, dependent: :destroy
    has_many :work_plans, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    # validates :terms_reference, presence: true
    # validates :terms_start, presence: true
    # validates :terms_end, presence: true
    validate :terms_end_greater_than_terms_start
    # validates :contractor, presence: true
    # validates :cnpj, presence: true
    # validates :status, presence: true
        
    STATUSES = ['active', 'closed', 'canceled', 'new'].freeze

    def self.status_options
        STATUSES.map { |status| [I18n.t("statuses.contract.#{status}"), status] }
    end

    private

    def terms_end_greater_than_terms_start
        if terms_end.present? && terms_start.present? && terms_end < terms_start + 3.months
            errors.add(:terms_end, l(:error_terms_end_date)) 
        end
    end
end

