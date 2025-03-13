Redmine::Plugin.register :redmine_gercont do
  name 'Redmine Gercont plugin'
  author 'Diogo Mattioli Neiva'
  description 'Este é um plugin para gerenciamento de contratos de prestação de serviços.'

  version '0.0.1'
  url 'https://github.com/dgmttl/redmine_plugdev'
  author_url 'www.linkedin.com/in/diogo-mattioli-neiva-9a5b77b0'

  Dir[File.join(File.dirname(__FILE__), '/lib/redmine_gercont/patches/*.rb')].each { |file| require_dependency file }


# Permissions
  project_module :redmine_gercont do
    permission :view_sla_event, {:sla_events => [:index, :show]}
    permission :manage_sla_event, {:sla_events => [:new, :create, :edit, :update, :destroy]}
    permission :view_assessment_menu, {:assessments => [:index, :show]}
    permission :manage_assessment, {:assessments => [:new, :create, :edit, :update, :destroy]}
    permission :view_work_plans_menu, {:work_plans => [:index]}
    permission :view_work_plans, {:work_plans => [:show]}
    permission :manage_work_plans, {:work_plans => [:new, :create, :edit, :update, :destroy]}
    permission :view_work_orders_menu, {:work_orders => [:index]}
    permission :view_work_orders, {:work_orders => [:show]}
    permission :manage_work_orders, {:work_orders => [:new, :create, :edit, :update, :destroy]}
    permission :view_work_order_professionals_menu, {:work_order_professionals => [:index]}
    permission :view_work_order_professionals, {:work_order_professionals => [:show]}
    permission :manage_work_order_professionals, {:work_order_professionals => [:new, :create, :edit, :update, :destroy]}
  end 

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
  menu :project_menu, 
    :sla_events, 
    { controller: 'sla_events', action: 'index' }, 
    if: Proc.new { User.current.allowed_to_globally?(:view_sla_event_menu) },
    caption: :label_sla_short, 
    after: :work_order_professionals, 
    param: :project_id

  menu :application_menu, 
    :sla_events, 
    { controller: 'sla_events', action: 'index'}, 
    if: Proc.new { User.current.allowed_to_globally?(:view_sla_event_menu) },
    caption: :label_sla_short
  
  
  # Assessment
  menu :project_menu, 
    :assessments, 
    { controller: 'assessments', action: 'index'},
    if: Proc.new { User.current.allowed_to_globally?(:view_assessment_menu) },
    caption: :label_assessments, 
    after: :sla_events, 
    param: :project_id

  menu :application_menu, 
    :assessments, 
    { controller: 'assessments', action: 'index'},
    if: Proc.new { User.current.allowed_to_globally?(:view_assessment_menu) },
    caption: :label_assessments


  # work_plan
  menu :project_menu, 
    :work_plans, 
    { controller: 'work_plans', action: 'index'},
    if: Proc.new { User.current.allowed_to_globally?(:view_work_plans) },
    caption: :label_work_plans, 
    after: :roadmap, 
    param: :project_id

  menu :application_menu, 
    :work_plans, 
    { controller: 'work_plans', action: 'index'},
    if: Proc.new { User.current.allowed_to_globally?(:view_work_plans_menu) },
    caption: :label_work_plans

# work_order
menu :project_menu, 
  :work_orders, 
  { controller: 'work_orders', action: 'index'},
  if: Proc.new { User.current.allowed_to_globally?(:view_work_orders) },
  caption: :label_work_orders, 
  after: :work_plans, 
  param: :project_id

menu :application_menu, 
  :work_orders, 
  { controller: 'work_orders', action: 'index'},
  if: Proc.new { User.current.allowed_to_globally?(:view_work_orders_menu) },
  caption: :label_work_orders



  # work_order_professional
  menu :project_menu, 
    :work_order_professionals, 
    { controller: 'work_order_professionals', action: 'index'},
    if: Proc.new { User.current.allowed_to_globally?(:view_work_order_professionals) },
    caption: :label_work_order_professionals, 
    after: :work_orders, 
    param: :project_id

  menu :application_menu, 
    :work_order_professionals, 
    { controller: 'work_order_professionals', action: 'index'},
    if: Proc.new { User.current.allowed_to_globally?(:view_work_order_professionals_menu) },
    caption: :label_work_order_professionals


  settings default: {'empty' => true}, partial: 'settings/redmine_gercont'

end


