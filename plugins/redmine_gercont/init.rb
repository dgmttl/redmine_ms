Redmine::Plugin.register :redmine_gercont do
  name 'Redmine Gercont plugin'
  author 'Diogo Mattioli Neiva'
  description 'Este é um plugin para gerenciamento de contratos de prestação de serviços.'

  version '0.0.1'
  url 'https://github.com/dgmttl/redmine_plugdev'
  author_url 'www.linkedin.com/in/diogo-mattioli-neiva-9a5b77b0'

  Dir[File.join(File.dirname(__FILE__), '/lib/redmine_gercont/patches/*.rb')].each { |file| require_dependency file }



  #Plan
  permission :approve_plan, {:versions => [:approve_plan]}
  permission :ask_for_plan_approval, {:versions => [:ask_for_plan_approval]}

  #Contract
  permission :view_contract, {
    :contracts => [:index]
  }
  permission :manage_contract, {
    :contracts => [:new, :create, :edit, :update, :destroy],
    :items => [:new, :create, :edit, :update, :destroy],
    :slas => [:new, :create, :edit, :update, :destroy],
    :rules => [:new, :create, :edit, :update, :destroy],
    :holidays =>  [:new, :create, :edit, :update, :destroy],
    :contract_members =>  [:new, :create, :edit, :update, :destroy]
  }
  
  menu :top_menu, 
    :contracts, 
    { controller: 'contracts',  action: 'index' },
    if: Proc.new { User.current.allowed_to_globally?(:view_contract) },
    caption: :label_contracts
  
  #SLA Event
  project_module :slas do
    permission :view_sla_event, {:sla_events => [:index, :show]}
    permission :manage_sla_event, {:sla_events => [:new, :create, :edit, :update, :destroy]}
  end   
  
  menu :project_menu, 
    :sla_events, 
    { controller: 'sla_events', action: 'index' }, 
    # if: Proc.new { User.current.allowed_to_globally?(:view_sla_event_menu) || User.current.admin?},
    caption: :label_sla_short, 
    after: :activity, 
    param: :project_id

  menu :application_menu, 
    :sla_events, 
    { controller: 'sla_events', action: 'index'}, 
    # if: Proc.new { User.current.allowed_to_globally?(:view_sla_event_menu) || User.current.admin? },
    caption: :label_sla_short

  
  
  # Assessment
  project_module :assessments do
    permission :view_assessment_menu, {:assessments => [:index, :show]}
    permission :manage_assessment, {:assessments => [:new, :create, :edit, :update, :destroy]}
  end   
  
  menu :project_menu, 
    :assessments, 
    { controller: 'assessments', action: 'index'},
    # if: Proc.new { User.current.allowed_to_globally?(:view_assessment_menu) },
    caption: :label_assessments, 
    after: :activity, 
    param: :project_id

  menu :application_menu, 
    :assessments, 
    { controller: 'assessments', action: 'index'},
    if: Proc.new { User.current.allowed_to_globally?(:view_assessment_menu) },
    caption: :label_assessments


  # work_plan
  project_module :work_plans do
    permission :view_work_plans_menu, {:work_plans => [:index]}
    permission :view_work_plans, {:work_plans => [:show]}
    permission :manage_work_plans, {:work_plans => [:new, :create, :edit, :update, :destroy]}
  end   

  menu :project_menu, 
    :work_plans, 
    { controller: 'work_plans', action: 'index'},
    # if: Proc.new { User.current.allowed_to_globally?(:view_work_plans) },
    caption: :label_work_plans, 
    after: :activity, 
    param: :project_id

  menu :application_menu, 
    :work_plans, 
    { controller: 'work_plans', action: 'index'},
    # if: Proc.new { User.current.allowed_to_globally?(:view_work_plans_menu) },
    caption: :label_work_plans    


  settings default: {'empty' => true}, partial: 'settings/redmine_gercont'

end


