class WorkPlanItem < ApplicationRecord
    self.table_name = 'contract_work_plan_items'
  
    belongs_to :work_plan
    belongs_to :item

    validates :item_id, presence: true
    validates :sprints, presence: true
    validates :rationale, presence: true
   
  
    def total
        return nil unless quantity && item&.daily_cost && percentage && sprints
        
        quantity * 
        item&.daily_cost * 
        (percentage / 100) * 
        estimated_calendar_days(
            JSON.parse(sprints).count * Setting.plugin_scrum['default_sprint_days'].to_i, 
            self.work_plan.days_allocation
        )
    end
      
    def calendar_days(work_days, start_date)
      holidays = contract_holidays_within_period
      calendar_days = 0
      counted_work_days = 0
    
      while counted_work_days < work_days
        calendar_days += 1
        current_date = start_date + calendar_days
  
        unless current_date.saturday? || current_date.sunday? || holidays.include?(current_date)
          counted_work_days += 1
        end
  
        # Se o último dia útil for uma sexta-feira, incluir sábado, domingo e feriados
        if counted_work_days == work_days && current_date.friday?
          calendar_days += 1 while current_date.saturday? || current_date.sunday? || holidays.include?(current_date += 1)
        end
      end
      calendar_days
    end

    def estimated_calendar_days(work_days, days_allocation)
      holidays = contract_holidays_within_period
      max_calendar_days = 0
      
      (0..days_allocation).each do |allocation|
        calendar_days = 0
        counted_work_days = 0
   
        while counted_work_days < work_days
          current_date = Holiday.next_work_day + allocation + calendar_days
          calendar_days += 1
          unless current_date.saturday? || current_date.sunday? || holidays.include?(current_date)
            counted_work_days += 1
          end
    
          if counted_work_days == work_days && current_date.friday?
            current_date += 1
            while   current_date.saturday? || current_date.sunday? || holidays.include?(current_date)
              calendar_days += 1
              current_date += 1
            end
          end
        end
    
        max_calendar_days = [max_calendar_days, calendar_days].max
      end
      max_calendar_days
    end

    private


    def contract_holidays_within_period
        Holiday.where(contract_id: item.contract.id)
            .pluck(:date)
    end
end