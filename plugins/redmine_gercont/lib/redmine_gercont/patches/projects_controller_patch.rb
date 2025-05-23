module RedmineGercont
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.class_eval do

          helper VersionsHelper

          alias_method :original_settings, :settings
          def settings
            original_settings
            if @project.contracts.any?
              @versions = @project.versions
            end
          end

        end
      end
    end
  end
end
  
ProjectsController.send(:include, RedmineGercont::Patches::ProjectsControllerPatch)

  