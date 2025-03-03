module RedmineGercont
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do

          has_many :assessments, dependent: :destroy
          has_many :contract_members

        end
      end
    end
  end
end

User.send(:include, RedmineGercont::Patches::UserPatch)