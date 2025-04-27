module RedmineGercont
  module DefaultData
    class DataAlreadyLoaded < StandardError; end
    module Loader
      include Redmine::I18n

      class << self
        # Returns true if no data is already loaded in the database
        # otherwise false
        
        def out_dated?
          version = Redmine::Plugin.find(:redmine_gercont).version
          core_settings_version = Setting.plugin_redmine_gercont['core_settings_version'] || '0.0.0'
          Gem::Version.new(version) > Gem::Version.new(core_settings_version)
        end

        def load(lang=nil, options={})
          # raise DataAlreadyLoaded.new("Some configuration data is already loaded.") unless no_data?
          set_language_if_valid(lang)
          # workflow = !(options[:workflow] == false)

          # story and tasks statuses
          new = IssueStatus.find_by(name: l(:default_issue_status_new))
          new.update!(default_done_ratio: 0)

          in_progress = IssueStatus.find_by(name: l(:default_issue_status_in_progress))
          in_progress.update!(default_done_ratio: 50)

          resolved = IssueStatus.find_by(name: l(:default_issue_status_resolved))
          resolved.update!(default_done_ratio: 80)

          feedback = IssueStatus.find_by(name: l(:default_issue_status_feedback))
          feedback.update!(default_done_ratio: 70)

          closed = IssueStatus.find_by(name: l(:default_issue_status_closed))
          closed.update!(default_done_ratio: 100)

          rejected = IssueStatus.find_by(name: l(:default_issue_status_rejected))
          rejected.update!(default_done_ratio: 100)

          puts "============= Builtin statuses done."

          # Demand statuses
          request_approval = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_request_approval))
          request_approval.save(validate: false)

          technical_review = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_technical_review))
          technical_review.save(validate: false)

          managerial_review = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_managerial_review))
          managerial_review.save(validate: false)

          request_adjust = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_request_adjustment))
          request_adjust.save(validate: false)

          approve = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_approve))
          approve.save(validate: false)

          ready_for_workplan = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_ready_for_workplan))
          ready_for_workplan.save(validate: false)

          develop_work_plan = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_develop_work_plan))
          develop_work_plan.save(validate: false)

          plan_drafting = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_plan_drafting))
          plan_drafting.save(validate: false)

          request_work_plan_approval = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_request_work_plan_approval))
          request_work_plan_approval.save(validate: false)

          technical_plan_review = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_technical_plan_review))
          technical_plan_review.save(validate: false)

          business_plan_review = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_business_plan_review))
          business_plan_review.save(validate: false)

          managerial_plan_review = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_managerial_plan_review))
          managerial_plan_review.save(validate: false)
          
          request_work_plan_adjustment  = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_request_work_plan_adjustment))
          request_work_plan_adjustment.save(validate: false)

          approve_work_plan = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_approve_work_plan))
          approve_work_plan.save(validate: false)

          waiting_work_order = IssueStatus.find_or_initialize_by(name: l(:default_issue_status_waiting_work_order))
          waiting_work_order.save(validate: false)

          generate_work_order = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_generate_work_order))
          generate_work_order.save(validate: false)

          staff_allocation = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_staff_allocation))
          staff_allocation.save(validate: false)

          allocate_professionals = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_allocate_professionals))
          allocate_professionals.save(validate: false)

          ready_to_start = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_ready_to_start))
          ready_to_start.save(validate: false)

          service_in_progress = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_service_in_progress))
          service_in_progress.save(validate: false)

          service_suspended = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_service_suspended))
          service_suspended.save(validate: false)

          technical_service_review = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_technical_service_review))
          technical_service_review.save(validate: false)

          business_service_review = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_business_service_review))
          business_service_review.save(validate: false)

          managerial_service_review = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_managerial_service_review))
          managerial_service_review.save(validate: false)

          accept_service = IssueStatus.find_or_initialize_by(:name => l(:default_issue_status_accept_service))
          accept_service.save(validate: false)
          
          puts "============= New statuses done."

          # Trackers
          demand = Tracker.find_or_initialize_by(:name => l(:default_tracker_demand))
          demand.update(
            :default_status_id => new.id, 
            :is_in_roadmap => false, 
            :position => 1,
            :core_fields => [
              "assigned_to_id", 
              "start_date", 
              "due_date", 
              "estimated_hours", 
              "done_ratio", 
              "description", 
              "priority_id"
            ]
          )

          story = Tracker.find_or_initialize_by(:name => l(:default_tracker_story)) 
            story.update(
              :default_status_id => new.id, 
              :is_in_roadmap => true, 
              :position => 2,
              :core_fields => [
                "assigned_to_id", 
                "fixed_version_id", 
                "parent_issue_id", 
                "start_date", 
                "due_date", 
                "estimated_hours", 
                "done_ratio", 
                "description", 
                "priority_id"
              ]
            )

          task = Tracker.find_or_initialize_by(:name => l(:default_tracker_task))
          task.update(
            :default_status_id => new.id, 
            :is_in_roadmap => false, 
            :position => 3,
            :core_fields => [
              "assigned_to_id", 
              "parent_issue_id", 
              "start_date", 
              "due_date", 
              "done_ratio", 
              "description", 
              "priority_id"
            ]
          )
          puts "============= Trackers done."

          # Roles
            contract_admin = Role.find_or_initialize_by(:name => l(:default_role_contract_admin))
            contract_admin.update(
              :position => 4,
              :assignable => false,
              :permissions => [
                :add_project, 
                :edit_project, 
                :close_project, 
                :manage_members, 
                :add_subprojects, 
                :manage_project_workflow, 
                :view_contract, 
                :manage_contract, 
                :view_issues, 
                :view_checklists,
                :view_sprint_board, 
                :view_product_backlog, 
                :view_release_plan
              ],
              :issues_visibility => "all",
              :users_visibility => "all",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"1", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "add_issues"=>[], 
                  "edit_issues"=>[], 
                  "add_issue_notes"=>[], 
                  "delete_issues"=>[]
                }
              }
            )


            contract_manager = Role.find_or_initialize_by(:name => l(:default_role_contract_manager))
            contract_manager.update(
              :position => 5,
              :assignable => true,
              :permissions => [
                :view_contract,
                :view_issues,
                :edit_issues,
                :add_issue_notes,
                :edit_own_issue_notes,
                :view_checklists,
                :view_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                },
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "edit_issues"=>[demand.id],
                  "add_issue_notes"=>[demand.id], 
                  "add_issues"=>[], 
                  "delete_issues"=>[]
                }
              }
            )


            technical_inspector = Role.find_or_initialize_by(:name => l(:default_role_technical_inspector))
            technical_inspector.update(
              :position => 6,
              :assignable => true,
              :permissions => [
                :view_contract, 
                :view_issues, 
                :edit_issues, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_checklists,
                :view_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "edit_issues"=>[demand.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "add_issues"=>[], 
                  "delete_issues"=>[]
                }
              }
          )


            administrative_inspector = Role.find_or_initialize_by(:name => l(:default_role_administrative_inspector))
            administrative_inspector.update(
              :position => 7,
              :assignable => true,
              :permissions => [
                :view_issues,
                :view_checklists
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "add_issues"=>[], 
                  "edit_issues"=>[], 
                  "add_issue_notes"=>[], 
                  "delete_issues"=>[]
                }
              }
          )


            requester = Role.find_or_initialize_by(:name => l(:default_role_requester))
            requester.update(
              :position => 8,
              :assignable => true,
              :permissions => [
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_checklists,
                :view_product_backlog, 
                :edit_product_backlog, 
                :sort_product_backlog,
                :view_checklists,
                :edit_checklists
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "add_issues"=>[demand.id, story.id], 
                  "edit_issues"=>[demand.id, story.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "delete_issues"=>[]
                }
              }
            )



            agent = Role.find_or_initialize_by(:name => l(:default_role_agent))
            agent.update(
              :position => 9,
              :assignable => true,
              :permissions => [
                :manage_members, 
                :view_issues,
                :edit_issues, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_checklists,
                :view_product_backlog, 
                :view_release_plan
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "add_issues"=>[], 
                  "edit_issues"=>[demand.id], 
                  "add_issue_notes"=>[demand.id, story.id, task.id], 
                  "delete_issues"=>[]
                }
              }
            )


            product_owner = Role.find_or_initialize_by(:name => l(:default_role_product_owner))
            product_owner.update(
              :position => 10,
              :assignable => true,
              :permissions => [
                :manage_versions, 
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :manage_issue_relations, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_checklists,
                :view_product_backlog, 
                :check_dependencies, 
                :edit_product_backlog, 
                :sort_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id], 
                  "add_issues"=>[story.id], 
                  "edit_issues"=>[story.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "delete_issues"=>[]
                }
              }
            )
            


            scrum_master = Role.find_or_initialize_by(:name => l(:default_role_scrum_master))
            scrum_master.update(
              :position => 11,
              :assignable => true,
              :permissions => [
                :manage_members, 
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :manage_issue_relations, 
                :manage_subtasks, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_checklists,
                :plan_work_plan,
                :save_release_plan,
                :manage_sprints, 
                :view_sprint_board, 
                :edit_sprint_board, 
                :sort_sprint_board, 
                :view_product_backlog, 
                :edit_product_backlog, 
                :sort_product_backlog, 
                :check_dependencies,
                :view_release_plan
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "edit_issues"=>[demand.id, story.id, task.id], 
                  "add_issue_notes"=>[demand.id, story.id, task.id], 
                  "add_issues"=>[story.id, task.id], 
                  "delete_issues"=>[]
                }
              }
            )


            scrum_team = Role.find_or_initialize_by(:name => l(:default_role_scrum_team))
            scrum_team.update(
              :position => 12,
              :assignable => true,
              :permissions => [
                :view_issues, 
                :add_issues, 
                :edit_issues, 
                :edit_own_issues, 
                :add_issue_notes, 
                :edit_own_issue_notes, 
                :view_checklists,
                :view_sprint_board, 
                :edit_sprint_board, 
                :sort_sprint_board, 
                :view_product_backlog
              ],
              :issues_visibility => "default",
              :users_visibility => "members_of_visible_projects",
              :settings => {
                "permissions_all_trackers"=>{
                  "view_issues"=>"0", 
                  "add_issues"=>"0", 
                  "edit_issues"=>"0", 
                  "add_issue_notes"=>"0", 
                  "delete_issues"=>"0"
                }, 
                "permissions_tracker_ids"=>{
                  "view_issues"=>[demand.id, story.id, task.id], 
                  "edit_issues"=>[demand.id, story.id], 
                  "add_issue_notes"=>[demand.id, story.id], 
                  "add_issues"=>[task.id], 
                  "delete_issues"=>[]
                }
              }
            )

            agent.update( all_roles_managed: false, managed_roles: [ agent, scrum_master, scrum_team ])
            scrum_master.update( all_roles_managed: false, managed_roles: [ scrum_master, scrum_team ])

            Role.non_member.update_attribute :permissions, [:view_issues]
            Role.anonymous.update_attribute :permissions, []
            puts "============= Roles done."


          # Custom fields
          story_points = IssueCustomField.find_or_initialize_by(
            :name => l(:default_field_story_points))
          story_points.update(
            :field_format => 'list',            
            :possible_values => ['1', '2', '3', '5', '8', '13','21'],
            :is_filter => 1,
            :visible => 1,
            :tracker_ids => [story.id], 
            :is_for_all => 1
          )

          blocked = IssueCustomField.find_or_initialize_by(
            :name => l(:default_field_blocked))
          blocked.update(
            :field_format => 'bool',
            :edit_tag_style => 'radio',
            :is_required => 1,
            :default_value => '0',
            :is_filter => 1,
            :visible => 1,
            :tracker_ids => [story.id], 
            :is_for_all => 1
          )

            
          versions = IssueCustomField.find_or_initialize_by(
            :name => l(:default_field_versions))
          versions.update(
            :field_format => 'version',
            :edit_tag_style => 'check_box',
            :multiple => 1,
            # :is_required => 1,
            :visible => 1,
            :tracker_ids => [demand.id], 
            :is_for_all => 1,
            :version_status => ["planning", "planned", "rejected"]
          )

          type = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_project_type))
          type.update(
            :field_format => 'enumeration',
            :edit_tag_style => 'check_box',
            :multiple => 1,
            :is_filter => 1,
            :visible => 1
          )
          
          dev = CustomFieldEnumeration.find_or_initialize_by(:name => l(:default_field_project_type_development))
          dev.update(:custom_field => type)
          
          mnt = CustomFieldEnumeration.find_or_initialize_by(:name => l(:default_field_project_type_maintenance))
          mnt.update(:custom_field => type)

          type.update(:default_value => mnt.id)
          
          requester_unity = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_requester_unity))
          requester_unity.update(
            :field_format => 'list',
            :possible_values => [
              "GM - CNS - Conselho Nacional de Saúde",
              "GM - AECI - Assessoria Especial de Controle Interno",
              "GM - AISA - Assessoria Especial de Assuntos Internacionais",
              "GM - APSD - Assessoria de Participação Social e Diversidade",
              "GM - ASCOM - Assessoria Especial de Comunicação Social",
              "GM - ASPAR - Assessoria Especial de Assuntos Parlamentares e Federativos",
              "GM - CONJUR - Consultoria Jurídica",
              "GM - CORREG - Corregedoria",
              "GM - DENASUS - Departamento Nacional de Auditoria do Sistema Único de Saúde",
              "GM - GABINETE - Gabinete do Ministro",
              "GM - OUVSUS - Ouvidoria-Geral do Sistema Único de Saúde",
              "SAES - DAET - Departamento de Atenção Especializada e Temática",
              "SAES - DAHU - Departamento de Atenção Hospitalar, Domiciliar e de Urgência",
              "SAES - DCEBAS - Departamento de Certificação de Entidades Beneficentes de Assistência Social em Saúde",
              "SAES - DESMAD - Departamento de Saúde Mental, Álcool e Outras Drogas",
              "SAES - DGH - Departamento de Gestão Hospitalar no Estado do Rio de Janeiro",
              "SAES - DRAC - Departamento de Regulação Assistencial e Controle",
              "SAES - HOSPITAIS FEDERAIS",
              "SAES - INC - Instituto Nacional de Cardiologia",
              "SAES - INCA - Instituto Nacional de Câncer",
              "SAES - INTO - Instituto Nacional de Traumatologia e Ortopedia",
              "SAPS - DEPPROS - Departamento de Prevenção e Promoção da Saúde",
              "SAPS - DESCO - Departamento de Estratégias e Políticas de Saúde Comunitária",
              "SAPS - DGAPS - Departamento de Apoio à Gestão da Atenção Primária",
              "SAPS - DGCI - Departamento de Gestão do Cuidado Integral",
              "SE - DECOOP - Departamento de Cooperação Técnica e Desenvolvimento em Saúde",
              "SE - DGIP - Departamento de Gestão Interfederativa e Participativa",
              "SE - DJUD - Departamento de Gestão das Demandas em Judicialização na Saúde",
              "SE - DLOG - Departamento de Logística em Saúde",
              "SE - FNS - Diretoria-Executiva do Fundo Nacional de Saúde",
              "SE - SAA - Subsecretaria de Assuntos Administrativos",
              "SE - SPO - Subsecretaria de Planejamento e Orçamento",
              "SECTICS - DAF - Departamento de Assistência Farmacêutica e Insumos Estratégicos",
              "SECTICS - DECEIIS - Departamento do Complexo Econômico-Industrial da Saúde e de Inovação para o SUS",
              "SECTICS - DECIT - Departamento de Ciência e Tecnologia",
              "SECTICS - DESID - Departamento de Economia e Desenvolvimento em Saúde",
              "SECTICS - DGITS - Departamento de Gestão e Incorporação de Tecnologias em Saúde",
              "SEIDIGI - DATASUS - Departamento de Informação e Informática do Sistema Único de Saúde",
              "SEIDIGI - DEMAS - Departamento de Monitoramento, Avaliação e Disseminação de Informações Estratégicas em Saúde",
              "SEIDIGI - DESD - Departamento de Saúde Digital e Inovação",
              "SESAI - DAPSI - Departamento de Atenção Primária à Saúde Indígena",
              "SESAI - DEAMB - Departamento de Projetos e Determinantes Ambientais da Saúde Indígena",
              "SESAI - DGESI - Departamento de Gestão da Saúde Indígena",
              "SESAI - DSEI - Distritos Sanitários Especiais",
              "SGTES - DEGERTS - Departamento de Gestão e Regulação do Trabalho em Saúde",
              "SGTES - DEGES - Departamento de Gestão da Educação na Saúde",
              "SVSA - CENP - Centro Nacional de Primatas",
              "SVSA - DAENT - Departamento de Análise Epidemiológica e Vigilância de Doenças Não Transmissíveis",
              "SVSA - DAEVS - Departamento de Ações Estratégicas de Epidemiologia e Vigilância em Saúde e Ambiente",
              "SVSA - DATHI - Departamento de HIV/AIDS, Tuberculose, Hepatites Virais e Infecções Sexualmente Transmissíveis",
              "SVSA - DEDT - Departamento de Doenças Transmissíveis",
              "SVSA - DEMSP - Departamento de Emergências em Saúde Pública",
              "SVSA - DPNI - Departamento do Programa Nacional de Imunizações",
              "SVSA - DVSAT - Departamento de Vigilância em Saúde Ambiental e Saúde do Trabalhador",
              "SVSA - IEC - Instituto Evandro Chagas"
            ],
            :is_filter => 1,
            :is_required => 1,
            :visible => 1
          )

          platform = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_platform))
          platform.update(
            :field_format => 'list',
            :possible_values => [
              'Mobile',
              'Portal',
              'Sistema',
              'SOA'
          ],
          :is_filter => 1,
          :is_required => 1,
          :visible => 1
          )

          mainteiner = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_mainteiner))
          mainteiner.update(
            :field_format => 'list',
            :possible_values => [
              'DATASUS',
              'Área negocial'
            ],
            :is_filter => 1,
            :is_required => 1,
            :visible => 1
          )

          operacional_sistem = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_operacional_sistem))
          operacional_sistem.update(
            :field_format => 'list',
            :possible_values => [
              '-',
              'Windows Server 2008R2',
              'Windows Server 2012',
              'Red Hat Linux 6',
              'Red Hat Linux 7'
            ],
            :is_filter => 1,
            :is_required => 1,
            :visible => 1
          )

          web_server = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_web_server))
          web_server.update(
            :field_format => 'list',
            :possible_values => [
              '-',
              'PHP 5.6',
              'Java Jboss EAP 6.4',
              'Big IP F5',
              'Nginx',
              'Embutido no Spring Boot'
            ],
            :is_filter => 1,
            :is_required => 1,
            :visible => 1
          )

          sgbd = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_sgbd))
          sgbd.update(
            :field_format => 'list',
            :possible_values => [
              '-',
              'Access',
              'Firebird',
              'MySQL 5',
              'Oracle 11g',
              'Oracle Data Integrator (ODI)',
              'Oracle 12c',
              'PostgreeSQL',
              'SQL Server'
            ],
            :is_filter => 1,
            :is_required => 1,
            :visible => 1
          )

          programming_language = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_programming_language))
          programming_language.update(
            :field_format => 'list',
            :possible_values => [
              '-',
              '.NET',
              'AJAX',
              'Angular',
              'Apache Wicket',
              'ASP',
              'C',
              'C#',
              'C++',
              'CLIPPER',
              'ColdFusion',
              'DELPHI',
              'HTML',
              'IBM Maximo',
              'JAVA',
              'JavaScript',
              'JSF',
              'MicroStrategy',
              'PERL',
              'PHP',
              'PL-SQL(Oracle)',
              'PowerBuilder',
              'Primefaces',
              'PYTHON',
              'RichFaces',
              'RUBY',
              'Sharepoint',
              'Spring',
              'Sybase',
              'Symfony',
              'VB',
              'Zend Framework 1.x'
            ],
            :is_filter => 1,
            :is_required => 1,
            :visible => 1
          )

          stg_environment = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_stg_environment))
          stg_environment.update(
            :field_format => 'link',
            :description => l(:text_valid_url),
            :visible => 1,
            :regexp => "^(https?:\\/\\/)?([\\w\\-]+(\\.[\\w\\-]+)+)(:[0-9]{1,5})?(\\/[\\w\\-.,@?^=%&:/~+#]*)?$"
          )

          trn_environment = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_trn_environment))
            trn_environment.update(
            :field_format => 'link',
            :description => l(:text_valid_url),
            :visible => 1,
            :regexp => "^(https?:\\/\\/)?([\\w\\-]+(\\.[\\w\\-]+)+)(:[0-9]{1,5})?(\\/[\\w\\-.,@?^=%&:/~+#]*)?$"
          )

          prd_environment = ProjectCustomField.find_or_initialize_by(
            :name => l(:default_field_prd_environment))
            prd_environment.update(
            :field_format => 'link',
            :description => l(:text_valid_url),
            :visible => 1,
            :regexp => "^(https?:\\/\\/)?([\\w\\-]+(\\.[\\w\\-]+)+)(:[0-9]{1,5})?(\\/[\\w\\-.,@?^=%&:/~+#]*)?$"
          )




          estimated_count = VersionCustomField.find_or_initialize_by(
            :name => l(:default_field_estimated_count))
          estimated_count.update(
            :field_format => 'float',
            :thousands_delimiter => 1,
            :visible => 1
          )

          estimated_duration = VersionCustomField.find_or_initialize_by(
            :name => l(:default_field_estimated_duration))
          estimated_duration.update(
            :field_format => 'int',
            :thousands_delimiter => 1,
            :visible => 1
          )

          estimated_cost = VersionCustomField.find_or_initialize_by(
            :name => l(:default_field_estimated_cost))
          estimated_cost.update(
            :field_format => 'float',
            :thousands_delimiter => 1,
            :visible => 1
          )

          puts "============= Custom fields done."

          #General Settings
          Setting.default_language = 'pt-BR'
          Setting.new_project_user_role_id = contract_admin.id
          Setting.issue_done_ratio = 'issue_status'
          Setting.default_issue_start_date_to_creation_date = '0'

          puts "============= General settings done."

          # Plugin settings 
          gercont_settings = {
            :demand_tracker_id => demand.id.to_s,
            :role_for_contract_manager => contract_manager.id.to_s,
            :role_for_technical_inspector => technical_inspector.id.to_s,      
            :role_for_administrative_inspector => administrative_inspector.id.to_s,
            :role_for_agent => agent.id.to_s,
            :role_for_product_owner => product_owner.id.to_s,
            :role_for_contract_admin => contract_admin.id.to_s,
            :role_for_requester => requester.id.to_s,
            :roles_for_assessment => [scrum_team.id].map(&:to_s),     
            :statuses_for_edit_assessment => [technical_service_review.id].map(&:to_s),    
            :field_for_version_count => estimated_count.id.to_s,
            :field_for_version_duration => estimated_duration.id.to_s,        
            :field_for_version_cost => estimated_cost.id.to_s,
            :field_for_requested_versions => versions.id.to_s,
            :field_for_requester_unity => requester_unity.id.to_s,
            :field_for_project_type => type.id.to_s,
            :core_settings_version => Redmine::Plugin.find(:redmine_gercont).version
          }.transform_keys(&:to_s)
          Setting.send :plugin_redmine_gercont=, gercont_settings 

          scrum_settings = {
            :sprint_burndown => '0',
            :render_plugin_tips => '0',
            :story_points_custom_field_id => story_points.id.to_s,
            :blocked_custom_field_id => blocked.id.to_s,
            :simple_pbi_custom_field_id => '',
            :pbi_tracker_ids => [story.id].map(&:to_s),
            :task_tracker_ids => [task.id].map(&:to_s),
            "tracker_#{story.id}_fields".to_sym => [ "description", "fixed_version_id" ],
            "tracker_#{story.id}_custom_fields".to_sym => [ story_points.id.to_s, blocked.id.to_s ],
            "tracker_#{task.id}_fields".to_sym => [ "assigned_to_id", "category_id", "due_date", "done_ratio", "description" ],
            :auto_update_pbi_status => '0',
            :closed_pbi_status_id => '',
            :pbi_is_closed_if_tasks_are_closed => '0',
            :use_remaining_story_points => '0',
            :default_sprint_name => 'Sprint 1',
            :default_sprint_days => '5',
            :default_sprint_shared => '0',
            :postit_size => 'big',
            :random_posit_rotation => '1',
            "tracker_#{story.id}_color".to_sym => 'post-it-color-1',
            "tracker_#{task.id}_color".to_sym => 'post-it-color-2',
            :doer_color => 'post-it-color-5',
            :reviewer_color => 'post-it-color-3',
            :doer_reviewer_postit_user_field_id => '',
            :task_status_ids => [new.id, in_progress.id, resolved.id, feedback.id, closed.id].map(&:to_s),
            :clear_new_tasks_assignee => '0',
            :pbi_status_ids => [new.id, in_progress.id, resolved.id, feedback.id, closed.id].map(&:to_s),
            :inherit_pbi_attributes => '1',
            :lowest_speed => '70',
            :low_speed => '80',
            :high_speed => '140',
            :render_pbis_speed => '1',
            :render_tasks_speed => '1',
            "tracker_#{story.id}_sprint_board_fields".to_sym => ["fixed_version_id"],
            "tracker_#{task.id}_sprint_board_fields".to_sym => ["category_id"],
            :show_project_totals_on_sprint => '1',
            :sprint_burndown_day_zero => '1',
            :create_journal_on_pbi_position_change => '0',
            :check_dependencies_on_pbi_sorting => '0',
            :render_position_on_pbi => '1',
            :render_category_on_pbi => '1',
            :render_version_on_pbi => '1',
            :render_author_on_pbi => '0',
            :render_assigned_to_on_pbi => '0',
            :render_updated_on_pbi => '0',
            :show_project_totals_on_backlog => '0',
            :product_burndown_sprints => '4',
            :product_burndown_extra_sprints => '3',
            :product_backlog_default_velocity => '26'
          }.transform_keys(&:to_s)
          Setting.send :plugin_scrum=, scrum_settings

          puts "============= Plugin settings done."

          #users
          user_names = ContractMember.role_options.map(&:name) + Item.profile_options.map(&:first)

          users = []
          user_names.each do |name|
            login = generate_login(name)
            user = User.find_or_initialize_by(:login => login)
            user.update(
              :firstname => name.split.first.capitalize,
              :lastname => name.split[1..].join(' '),
              :mail => "#{login}@gercont.com"
            )
            
            user.password = '12345678'
            user.password_confirmation = '12345678'
            user.save
            users << user
          end
          puts "============= Users done."

          # Fields visibility
          trackers = Tracker.all
          core_fields = trackers.map(&:core_fields).flatten.uniq
          custom_fields_id = trackers.map(&:custom_fields).flatten.map(&:id).uniq.sort
          
          fields = [
            'project_id', 'tracker_id', 'subject', 
            'is_private', core_fields, custom_fields_id
          ].flatten
          
          roles = Role.all

          status_ids = IssueStatus.all.map(&:id)

          # Workflow permissions
          permissions = status_ids.each_with_object({}) do |status, permissions_hash|
            permissions_hash[status] = {}

            fields.each do |field|
              permissions_hash[status][field] = "readonly"
            end
          end
          WorkflowPermission.replace_permissions(trackers, roles, permissions)
          puts "============= Workflow permissions readonly done."


          # Workflows Transitions
          WorkflowTransition.replace_transitions(
            [demand], 
            [requester], {
            new.id => {
              rejected.id => { "always" => true },
              request_approval.id => { "always" => true }
            },
            request_adjust.id => {
              rejected.id => { "always" => true },
              request_approval.id => { "always" => true }
            }
          })
          
          WorkflowTransition.replace_transitions(
            [demand], 
            [technical_inspector], {
            technical_review.id => {
              approve.id => { "always" => true },
              request_adjust.id => { "always" => true }
            }
          })

          WorkflowTransition.replace_transitions(
            [demand], 
            [agent, scrum_master], {
            ready_for_workplan.id => {
              develop_work_plan.id => { "always" => true }
            }
          })

          WorkflowTransition.replace_transitions(
            [demand], 
            [scrum_master], {
            plan_drafting.id => {
              request_work_plan_approval.id => { "always" => true }
            }
          })

          WorkflowTransition.replace_transitions(
            [demand], 
            [contract_manager], {
            managerial_review.id => {
              approve.id => { "always" => true },
              request_adjust.id => { "always" => true },
              rejected.id => { "always" => true}
            }
          })

          WorkflowTransition.replace_transitions(
            [story], 
            [requester, product_owner], {
            new.id => { 
              rejected.id => { "always" => true }
            },
            resolved.id => {
              feedback.id =>{ "always" => true },
              closed.id =>{ "always" => true }
            }
          })
          puts "============= Workflow transitions done."


          # Workflows Permissions
          WorkflowPermission.replace_permissions(
            [demand],
            [requester],
            new.id.to_s => { 
              "tracker_id" => "", 
              "subject" => "",
              "description" => "", 
              "assigned_to_id" => "",
              "priority_id" => "",
              versions.id.to_s => ""
            },
            request_approval.id.to_s => {
              "subject" => "",
              "description" => "", 
              "assigned_to_id" => "",
              "priority_id" => "",
              versions.id.to_s => "required"
            },
            request_adjust.id.to_s => {
              "subject" => "",
              "description" => "", 
              "assigned_to_id" => "",
              "priority_id" => "",
              versions.id.to_s => "required"
            }
          )

          WorkflowPermission.replace_permissions(
            [demand],
            [technical_inspector],
            technical_review.id.to_s => { "assigned_to_id" => "" },
            request_adjust.id.to_s => { "assigned_to_id" => "" },
            approve.id.to_s => { "assigned_to_id" => "" }
          )

          WorkflowPermission.replace_permissions(
            [demand],
            [agent, scrum_master],
            ready_for_workplan.id.to_s => { "assigned_to_id" => "" },
            develop_work_plan.id.to_s => { "assigned_to_id" => "" }
          )

          WorkflowPermission.replace_permissions(
            [demand],
            [scrum_master],
            plan_drafting.id.to_s => { "assigned_to_id" => "" },
            request_work_plan_approval.id.to_s => { "assigned_to_id" => "" }
          )

          WorkflowPermission.replace_permissions(
            [demand],
            [contract_manager],
            managerial_review.id.to_s => { "assigned_to_id" => "" },
            request_adjust.id.to_s => { "assigned_to_id" => "" },
            approve.id.to_s => { "assigned_to_id" => "" }
          )

          WorkflowPermission.replace_permissions(
            [story],
            [requester, product_owner, scrum_master],
            new.id.to_s => { 
              "tracker_id" => "", 
              "subject" => "", 
              "description" => "",
              "priority_id" => ""
            }
          )

          WorkflowPermission.replace_permissions(
            [story],
            [product_owner, scrum_master],
            new.id.to_s => { 
              "fixed_version_id" => ""
            }
          )

          WorkflowPermission.replace_permissions(
            [story],
            [scrum_master],
            new.id.to_s => { 
              "parent_issue_id" => ""
            }
          )

          puts "============= Workflow permissions done."

          # Sample Project
          project = Project.find_or_initialize_by(:name => l(:default_project_name))
          project.update(
            :identifier => l(:default_project_name).downcase.gsub(" ", "_"),
            :is_public => false,
          )

          non_project_roles = ContractMember.role_options
          non_project_roles.delete_if { |role| role.name == l(:default_role_contract_admin) }
          project_users = users.select { |user| !non_project_roles.map(&:name).include?(user.name) }

          project_users.each do |user|
              role = roles.find { |role| role.name == user.name } || scrum_team
              register = Member.find_or_initialize_by(user_id: user.id)
              register.update(
                project_id: project.id,
                role_ids: [role.id]
              )
          end
          puts "============= Sample project done."

          # Custom Workflows
          CustomWorkflow.all.map(&:destroy) if CustomWorkflow.all.any?
          files = Dir.glob(File.join(Rails.root, 'plugins', 'redmine_gercont', 'lib', 'redmine_gercont', 'default_data', 'cw_scripts', '*.xml'))
          files.each do |file|
            workflow = CustomWorkflow.import_from_xml(File.read(file))
            workflow.string=''
            workflow.save
          end

          puts "============= CustomWorkflows done."
          
          # Queries
          pbi_query = IssueQuery.find_or_initialize_by(:name => l(:default_query_project_backlog_issues))
          pbi_query.update(
            :filters =>
              {
                'status_id' => {:operator => 'o', :values => ['']},
                'tracker_id' => {:operator => '=', :values => [story.id]},
                'parent_id'=> {:operator => '!*', :values => ['']}
              },
            :sort_criteria => [['position', 'asc']],
            :visibility => Query::VISIBILITY_PUBLIC,
            :column_names => [
              :tracker, 
              :status, 
              :priority, 
              :subject, 
              :sprint,
              :fixed_version,
              :position
            ]
          )

          demand_query = IssueQuery.find_or_initialize_by(:name => l(:default_query_project_demand_issues))
          demand_query.update(
            :filters =>
              {'tracker_id' => {:operator => '=', :values => [demand.id]}},
            :sort_criteria => [['id', 'desc']],
            :visibility => Query::VISIBILITY_PUBLIC
          )

          puts "============= Queries done."
         
          true
        end
        
        def generate_login(name)
          parts = name.split.map { |part| I18n.transliterate(part) }
          "#{parts.first.downcase}.#{parts.last.downcase}"
        end



      end
    end
  end
end
