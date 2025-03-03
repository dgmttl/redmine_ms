module HolidaysHelper
    def holiday_title(holiday)
        items = []
        items << [l(:label_contracts), contracts_path]
        items << [l(:label_holidays), contract_holiday_path] if holiday
        items << (holiday.nil? || holiday.new_record? ? l(:label_new_holiday) : holiday.description)
    
        title(*items)
    end

    def contract_holiday_path
        edit_contract_path(@holiday.contract, :tab => 'holiday')
    end
end
