class Holiday < ActiveRecord::Base
    self.table_name = 'contract_holidays'

    belongs_to :contract
    

    def self.next_work_day
        today = Date.today
        next_work_day = today
      
        loop do
          next_work_day += 1
          break unless next_work_day.saturday? || next_work_day.sunday? || Holiday.exists?(date: next_work_day)
        end
      
        next_work_day
    end

    def self.next_work_day_after(date)
        next_work_day = date
      
        loop do
          next_work_day += 1
          break unless next_work_day.saturday? || next_work_day.sunday? || Holiday.exists?(date: next_work_day)
        end
      
        next_work_day
    end

    def self.holidays_between(start_date, end_date)
        Holiday.where('date >= ? AND date <= ?', start_date, end_date).pluck(:date)
    end

    def self.calendar_days(work_days, start_date)
        holidays = Holiday.where('date >= ?', start_date).pluck(:date)
        calendar_days = 0
        counted_work_days = 0
        
        while counted_work_days < work_days
            calendar_days += 1
            current_date = start_date + calendar_days
    
            unless current_date.saturday? || current_date.sunday? || holidays.include?(current_date)
                counted_work_days += 1
            end
        end
        calendar_days
    end

end
