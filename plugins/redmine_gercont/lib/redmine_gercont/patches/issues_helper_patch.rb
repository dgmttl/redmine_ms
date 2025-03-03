module RedmineGercont
    module Patches
        module IssuesHelperPatch
            def self.included(base)
                base.class_eval do
                    
                    alias_method :original_issue_history_tabs, :issue_history_tabs
                    def issue_history_tabs
                        tabs = original_issue_history_tabs
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
                        tabs
                    end

                    alias_method :original_trackers_for_select, :trackers_for_select
                    def trackers_for_select(issue)
                        trackers = original_trackers_for_select(issue)
                        if User.current.roles_for_project(Project.first).include?(Role.find(Setting.plugin_redmine_gercont['role_for_product_owner'].to_i))
                            trackers = trackers.reject { |tracker| Setting.plugin_scrum['pbi_tracker_ids'].first.to_i == tracker.id }
                        end
                        trackers
                    end
                    
                end
            end
        end
    end
end

IssuesHelper.send(:include, RedmineGercont::Patches::IssuesHelperPatch)
  
  