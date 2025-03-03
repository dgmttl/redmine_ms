module RedmineGercont
  module Patches
    module TrackerPatch
      def self.included(base)
        base.class_eval do
          has_and_belongs_to_many :contracts
          has_many :rules
        end
      end
    end
  end
end

Tracker.send(:include, RedmineGercont::Patches::TrackerPatch)