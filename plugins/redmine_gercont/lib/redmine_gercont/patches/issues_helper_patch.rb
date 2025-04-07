module RedmineGercont
    module Patches
        module IssuesHelperPatch
            def self.included(base)
                base.class_eval do
                    
                    alias_method :original_issue_history_tabs, :issue_history_tabs
                    alias_method :original_trackers_for_select, :trackers_for_select                    
                    
                    def issue_history_tabs
                        tabs = original_issue_history_tabs

                        if @project.contracts.any?
                            if @issue.assessments.any?
                                tabs << {
                                    name: 'assessments',
                                    label: :label_assessments,
                                    partial: Setting.plugin_redmine_gercont["statuses_for_edit_assessment"]
                                                .map(&:to_i).include?(@issue.status_id) ? 'assessments/edit_for_issue' : 'assessments/index_for_issue'
                                }
                            end

                            if @issue.sla_events.any?
                                tabs << {
                                    name: 'sla_events',
                                    label: :label_slas,
                                    partial: 'sla_events/index_for_issue'
                                }
                            end

                            if @work_plan.present?
                                tabs << {
                                    name: 'work_plan',
                                    label: :label_work_plan,
                                    partial: 'work_plans/show'
                                }
                            end

                            if @work_order.present?
                                tabs << {
                                    name: 'work_orders',
                                    label: :label_work_order,
                                    partial: 'work_orders/show'
                                }
                            end

                            if @work_order_professionals.any?
                                tabs << {
                                    name: 'work_order_professionals',
                                    label: :label_work_order_professionals,
                                    partial: 'work_order_professionals/index_for_issue'
                                }
                            end
                        end

                        tabs
                    end


                    def trackers_for_select(issue)
                        trackers = original_trackers_for_select(issue)
                        if User.current.roles_for_project(Project.first).include?(Role.find(Setting.plugin_redmine_gercont['role_for_requester'].to_i))
                            trackers = trackers.reject { |tracker| Setting.plugin_scrum['pbi_tracker_ids'].first.to_i == tracker.id }
                        end
                        trackers
                    end

                    # def can_plan_work_plan?
                    #     ((@issue.work_plan.present? && ['planning', 'rejected'].include?(@issue.work_plan.status))  &&
                    #     User.current.allowed_to?(:plan_work_plan, @project)) || User.current.admin?
                    # end

                    # def can_approve_work_plan?
                    #    ((@issue.work_plan.present? && @issue.work_plan.status == 'planned')  &&
                    #     User.current.allowed_to?(:approve_work_plan, @project)) || User.current.admin?
                    # end

                    
                end
            end
        end
    end
end

IssuesHelper.send(:include, RedmineGercont::Patches::IssuesHelperPatch)
  
  