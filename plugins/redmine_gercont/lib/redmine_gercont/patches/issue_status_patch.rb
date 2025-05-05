module RedmineGercont
  module Patches
    module IssueStatusPatch
      def self.included(base)
        base.class_eval do
          # Métodos de classe que retornam o objeto correspondente
          def self.request_approval
            find_by(name: I18n.t(:default_issue_status_request_approval))
          end

          def self.technical_review
            find_by(name: I18n.t(:default_issue_status_technical_review))
          end

          def self.request_adjustment
            find_by(name: I18n.t(:default_issue_status_request_adjustment))
          end

          def self.approve
            find_by(name: I18n.t(:default_issue_status_approve))
          end

          def self.managerial_review
            find_by(name: I18n.t(:default_issue_status_managerial_review))
          end

          def self.ready_for_workplan
            find_by(name: I18n.t(:default_issue_status_ready_for_workplan))
          end

          def self.develop_work_plan
            find_by(name: I18n.t(:default_issue_status_develop_work_plan))
          end

          def self.plan_drafting
            find_by(name: I18n.t(:default_issue_status_plan_drafting))
          end

          def self.request_work_plan_approval
            find_by(name: I18n.t(:default_issue_status_request_work_plan_approval))
          end

          def self.technical_plan_review
            find_by(name: I18n.t(:default_issue_status_technical_plan_review))
          end

          def self.business_plan_review
            find_by(name: I18n.t(:default_issue_status_business_plan_review))
          end

          def self.managerial_plan_review
            find_by(name: I18n.t(:default_issue_status_managerial_plan_review))
          end

          def self.request_work_plan_adjustment
            find_by(name: I18n.t(:default_issue_status_request_work_plan_adjustment))
          end

          def self.approve_work_plan
            find_by(name: I18n.t(:default_issue_status_approve_work_plan))
          end

          def self.waiting_work_order
            find_by(name: I18n.t(:default_issue_status_waiting_work_order))
          end

          def self.generate_work_order
            find_by(name: I18n.t(:default_issue_status_generate_work_order))
          end

          def self.staff_allocation
            find_by(name: I18n.t(:default_issue_status_staff_allocation))
          end

          def self.allocate_professionals
            find_by(name: I18n.t(:default_issue_status_allocate_professionals))
          end

          def self.ready_to_start
            find_by(name: I18n.t(:default_issue_status_ready_to_start))
          end

          def self.service_in_progress
            find_by(name: I18n.t(:default_issue_status_service_in_progress))
          end

          def self.service_suspended
            find_by(name: I18n.t(:default_issue_status_service_suspended))
          end

          def self.technical_service_review
            find_by(name: I18n.t(:default_issue_status_technical_service_review))
          end

          def self.business_service_review
            find_by(name: I18n.t(:default_issue_status_business_service_review))
          end

          def self.managerial_service_review
            find_by(name: I18n.t(:default_issue_status_managerial_service_review))
          end

          def self.accept_service
            find_by(name: I18n.t(:default_issue_status_accept_service))
          end

          def self.new_status
            find_by(name: I18n.t(:default_issue_status_new))
          end
        end
      end
    end
  end
end

IssueStatus.send(:include, RedmineGercont::Patches::IssueStatusPatch)