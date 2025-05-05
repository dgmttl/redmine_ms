module RedmineGercont
  module Patches
    module TrackerPatch
      def self.included(base)
        base.class_eval do
          has_and_belongs_to_many :contracts
          has_many :rules

          def self.demand
            find_by(name: I18n.t(:default_tracker_demand))
          end

          def self.story
            find_by(name: I18n.t(:default_tracker_story))
          end

          def self.task
            find_by(name: I18n.t(:default_tracker_task))
          end

        end
      end
    end
  end
end

Tracker.send(:include, RedmineGercont::Patches::TrackerPatch)