module RedmineGercont
  module Patches
    module IssueRelationsHelperPatch
      def self.included(base)
        base.class_eval do
          
          alias_method :collection_for_relation_type_select_orig, :collection_for_relation_type_select
          def collection_for_relation_type_select
            collection_for_relation_type_select_orig.select do |item|
              item[1].include?('block')
            end
          end
        end
      end
    end
  end
end

IssueRelationsHelper.send(:include, RedmineGercont::Patches::IssueRelationsHelperPatch)