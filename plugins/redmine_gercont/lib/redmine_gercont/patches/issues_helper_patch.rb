module RedmineGercont
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.class_eval do
                  
          alias_method :original_issue_history_tabs, :issue_history_tabs
          alias_method :original_render_descendants_tree, :render_descendants_tree

          def issue_history_tabs
            tabs = original_issue_history_tabs

            if @project.contracts.any?
                
              if @work_plan.present?
                tabs.insert(0, {
                  name: 'work_plan',
                  label: :label_work_plan,
                  partial: 'work_plans/show'
                })
              end  

              if @work_order.present?
                tabs.insert(1, {
                  name: 'work_orders',
                  label: :label_work_order,
                  partial: 'work_orders/show'
                })
              end

              if @work_order_professionals.any?
                tabs.insert(2, {
                  name: 'work_order_professionals',
                  label: :label_work_order_professionals,
                  partial: 'work_order_professionals/index_for_issue'
                })
              end 

              if @issue.sla_events.any?
                tabs.insert( 3, {
                  name: 'sla_events',
                  label: :label_slas,
                  partial: 'sla_events/index_for_issue'
                })
              end                            
              
              if @issue.assessments.any?
                tabs.insert(4, {
                  name: 'assessments',
                  label: :label_assessments,
                  partial: Setting.plugin_redmine_gercont["statuses_for_edit_assessment"]
                      .map(&:to_i).include?(@issue.status_id) ? 'assessments/edit_for_issue' : 'assessments/index_for_issue'
                })
              end
            end
            tabs
          end


          def render_descendants_tree(issue)
              unless @issue.contracts_any?
                original_render_descendants_tree
              else
                manage_relations = can_plan_work_plan?
                s = +'<table class="list issues odd-even">'
                issue_list(
                issue.descendants.visible.
                  preload(:status, :priority, :tracker,
                    :assigned_to).sort_by(&:lft)) do |child, level|
                      css = "issue issue-#{child.id} hascontextmenu #{child.css_classes}"
                      css << " idnt idnt-#{level}" if level > 0
                      buttons =
                        if manage_relations
                          link_to(
                            sprite_icon('link-break', l(:label_delete_link_to_subtask)),
                            issue_path(
                            {:id => child.id, :issue => {:parent_issue_id => ''},
                            :back_url => issue_path(issue.id), :no_flash => '1'}
                            ),
                            :method => :put,
                            :data => {:confirm => l(:text_are_you_sure)},
                            :title => l(:label_delete_link_to_subtask),
                            :class => 'icon-only icon-link-break'
                        )
                        else
                        "".html_safe
                        end
                        buttons << link_to_context_menu
                        s <<
                          content_tag(
                          'tr',
                          content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil),
                            :class => 'checkbox') +
                              content_tag('td',
                                link_to_issue(
                                child,
                                :project => (issue.project_id != child.project_id)),
                                :class => 'subject') +
                              content_tag('td', h(child.status), :class => 'status') +
                              content_tag('td', link_to_user(child.assigned_to), :class => 'assigned_to') +
                              content_tag('td', format_date(child.start_date), :class => 'start_date') +
                              content_tag('td', format_date(child.due_date), :class => 'due_date') +
                              content_tag('td',
                                (if child.disabled_core_fields.include?('done_ratio')
                                    ''
                                else
                                    progress_bar(child.done_ratio)
                                end),
                                :class=> 'done_ratio') +
                              content_tag('td', buttons, :class => 'buttons'),
                          :class => css)
              end
              s << '</table>'
              s.html_safe
            end
          end
        end
      end
    end
  end
end

IssuesHelper.send(:include, RedmineGercont::Patches::IssuesHelperPatch)

