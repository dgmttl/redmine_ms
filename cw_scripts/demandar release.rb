if tracker_id == 1 && project.contracts.any? { |contract| contract.id == 14 }
 
 if requested_versions_changed?
    # Calcula os IDs adicionados ou removidos
    @requested = requested_versions_is - requested_versions_was
    @approved = requested_versions_was - requested_versions_is

    puts "requested: #{@requested}"
    puts "approved: #{@approved}"
    puts "story_ids(requested): #{stories_by_version_ids(@requested).pluck(:id)}"
    puts "story_ids(approved): #{stories_by_version_ids(@approved).pluck(:id)}"
    puts "parent_id: #{id}"
    puts "requested.present?: #{@requested.present?}"
    puts "approved.present?: #{@approved.present?}"

    # Atualiza os status para "requested" se houver mudanças
    if @requested.present?
      @demand_backlog = project.product_backlogs.find { |backlog| backlog.name == @issue.to_s.split(':')[0] } 
      puts "@backlog: #{@demand_backlog}"
      

      @stories_to_demand.concat(
        stories_by_version_ids(@requested).map do |story|
          story
        end
      )

    end

    # Atualiza os status para "approved" e remove parent_id se houver mudanças
    if @approved.present?
      @stories_out_demand.concat(
        stories_by_version_ids(@approved).map do |story|
          story
        end
      )
    end
  end

end


#################################AFTER SAVE###################
unless @demand_backlog.present?
  create_demand_backlog(@issue)
end

@stories_to_demand.each do |story|
  Version.where(id: @requested).update_all(status: 'planning')

  story.parent_id= id
  story.sprint_id= @demand_backlog.id
  story.save!

  Version.where(id: @requested).update_all(status: 'requested')

end if @stories_to_demand.present?
  
  
@stories_out_demand.each do |story|

    Version.where(id: @approved).update_all(status: 'planning')

    puts "+++++++++++++++ after_save - @default_pbi: #{project.product_backlogs.first}"
    puts "+++++++++++++++ after_save - stories_out_demand- story: #{story.id}, #{story.parent_id}"
    story.parent_id= nil
    story.sprint_id= project.product_backlogs.first.id
    story.save!
    puts "+++++++++++++++ after_save - stories_out_demand- story: #{story.id}, #{story.parent_id}"
    
    Version.where(id: @approved).update_all(status: 'approved')
    
  
  end if @stories_out_demand.present?