module WorkPlanItemsHelper

    def work_plan_item_title
        items = []
        items << [l(:label_work_plan), issue_path(@work_plan.issue, :tab => 'work_plan')]
        # items << [l(:label_work_plan_item), work_plan_item_path] if work_plan_item
        items << (@work_plan_item.nil? || @work_plan_item.new_record? ? l(:label_new_work_plan_item) : @work_plan_item.name)
    
        title(*items)
    end

end
