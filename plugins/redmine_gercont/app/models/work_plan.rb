class WorkPlan < ApplicationRecord
    self.table_name = 'contract_work_plans'

    belongs_to :issue
    # has_one :contract, through: :issue
    has_one :project, through: :issue
    has_one :work_order, through: :issue
    has_many :work_plan_items
    has_many :items, through: :work_plan_items

    validates :issue_id, uniqueness: true


    STATUSES = ['planning', 'planned', 'approved', 'rejected', 'closed'].freeze

    def self.status_options
        STATUSES.map { |status| [I18n.t("statuses.work_plan.#{status}"), status] }
    end


    def contract
        return nil if work_plan_items.empty?
        work_plan_items.first.item.contract
    end

    def available_sprints
        return [] if sprints.blank?
        JSON.parse(sprints, symbolize_names: true)
    end

    def sprints_objects
        return [] if available_sprints.blank?
        
        available_sprints.map do |sprint_data|
          {
            index: sprint_data[:index],
            versions: (sprint_data[:versions] || []).map { |version_id| Version.find_by(id: version_id) },
            pbis: (sprint_data[:pbis] || []).map { |pbi| Issue.find_by(id: pbi) },
            days: sprint_data[:days]
          }
        end
    end
      

    def total
        work_plan_items.map { |item| item.total.to_f }.sum.round(2)
    end
      
    def stories
        issue.children.where(tracker_id: Setting.plugin_scrum['pbi_tracker_ids'].first.to_i)
    end

    def deadline
        sprints_objects.last[:days]
    end

    def generate_baseline
        self.baseline = {
            work_plan: self.attributes, # Todos os atributos de @work_plan
            sprints_objects: self.sprints_objects.map do |sprint|
            {
                index: sprint[:index],
                versions: sprint[:versions].map(&:attributes), # Salva todos os atributos das versões
                pbis: sprint[:pbis].map(&:attributes), # Salva todos os atributos dos PBIs
                days: sprint[:days]
            }
            end,
            work_plan_items: self.work_plan_items.map do |item|
            {
                work_plan_item: item.attributes, # Todos os atributos do work_plan_item
                item: item.item.attributes # Todos os atributos do item associado
            }
            end
        }.to_json 
        
        # Serializa tudo como JSON
    end
    
    

    def load_baseline
        return unless self.baseline.present?
      
        baseline_data = JSON.parse(self.baseline)
      
        # Criando uma cópia do WorkPlan com os dados da baseline
        reconstructed_work_plan = self.dup
        reconstructed_work_plan.assign_attributes(baseline_data["work_plan"])
      
        # Substituir `sprints_objects` com dados da baseline
        reconstructed_work_plan.define_singleton_method(:sprints_objects) do
          baseline_data["sprints_objects"].map do |sprint_data|
            {
              index: sprint_data["index"],
              versions: sprint_data["versions"].map { |version_attrs| Version.new(version_attrs.symbolize_keys) },
              pbis: sprint_data["pbis"].map { |pbi_attrs| Issue.new(pbi_attrs.symbolize_keys) },
              days: sprint_data["days"]
            }
          end
        end
      
        # Substituir `work_plan_items` para usar exclusivamente os dados da baseline
        reconstructed_work_plan.define_singleton_method(:work_plan_items) do
          baseline_data["work_plan_items"].map do |item_data|
            work_plan_item = WorkPlanItem.new(item_data["work_plan_item"].symbolize_keys)
            work_plan_item.item = Item.new(item_data["item"].symbolize_keys)
            work_plan_item
          end
        end
      
        reconstructed_work_plan
      end




end
