module RedmineGercont
  module Patches
    module VersionPatch
      def self.included(base)
        base.class_eval do
          Version::VERSION_STATUSES.concat(%w(planning planned approved requested rejected))

          scope :open, -> {where(status: ['open', 'planning', 'planned', 'approved', 'requested', 'rejected'])}
          scope :planning, -> { where(status: 'planning')}
          scope :planned, -> { where(status: 'planned')}
          scope :rejected, -> { where(status: 'rejected')}
          scope :approved, -> { where(status: 'approved')}
          scope :requested, -> { where(status: 'requested')}
          scope :for_approve_or_not, -> {where(status: ['planned', 'rejected', 'approved']) }
          
          def self.plan_status(versions)
            return 'planning' if versions.empty?
          
            # Flags para verificar os estados das versões
            has_open = false
            has_blocked = false
            has_rejected = false
            has_approved = false
            has_planned = false
            has_closed = false
            has_requested = false
          
            # Percorre as versões para definir os estados
            versions.each do |version|
              case version.status
              when 'open'
                has_open = true
              when 'locked'
                has_blocked = true
              when 'requested'
                has_requested = true
              when 'rejected'
                has_rejected = true
              when 'approved'
                has_approved = true
              when 'planned'
                has_planned = true
              when 'closed'
                has_closed = true
              end
            end
          
            # Determina o status com base nas prioridades
            if has_blocked && !has_open
              'blocked' 
            elsif has_requested && !has_blocked && !has_open
              'requested' 
            elsif has_open  
              'attending' 
            elsif has_rejected || (has_approved && has_planned)
              'partially_approved' 
            elsif versions.all? { |v| v.status == 'approved' } || (has_approved && has_closed)
              'approved' 
            elsif versions.all? { |v| v.status == 'planned' }
              'approving' 
            elsif versions.all? { |v| v.status == 'closed' }
            'closed' 
            else
              'planning'
            end
          end
          
          
          
          
        end
      end
    end
  end
end

Version.send(:include, RedmineGercont::Patches::VersionPatch)
