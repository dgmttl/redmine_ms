# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :contracts, shallow: true do 
  resources :items
  resources :slas
  resources :rules
  resources :holidays
  resources :contract_members
end

resources :projects, shallow: true do
  resources :sla_events
  resources :assessments
  resources :work_plans, shallow: true do
    resources :work_plan_items
      # post :add_item, on: :member
      # delete :remove_item, on: :member
  end
  resources :work_orders
  resources :work_order_professionals
end


get 'sla_events', to: 'sla_events#index', as: 'sla_events'
get 'assessments', to: 'assessments#index', as: 'assessments'
get 'work_plans', to: 'work_plans#index', as: 'work_plans'
get 'work_orders', to: 'work_orders#index', as: 'work_orders'
get 'work_order_professionals', to: 'work_order_professionals#index', as: 'work_order_professionals'


post '/rules/:id/change_status', to: 'rules#change_status', as: 'rule_status'
put '/rules/:id/reorder', to: 'rules#reorder'
post '/sla/:id/change_status', to: 'slas#change_status', as: 'sla_status'

put 'update_assessments_by_issue', to: 'assessments#update_by_issue'

post 'update_versions_status', to: 'versions#approve_plan'
post 'ask_for_plan_approval', to: 'versions#ask_for_plan_approval'
post 'save_release_plan', to: 'work_plans#save_release_plan'
post 'ask_for_work_plan_approval', to: 'work_plans#ask_for_work_plan_approval'
post 'approve_work_plan', to: 'work_plans#approve_work_plan'
post 'reject_work_plan', to: 'work_plans#reject_work_plan'
post 'generate_work_order', to: 'work_orders#generate_work_order'

post '/contracts/default_configuration', :to => 'contracts#default_configuration'