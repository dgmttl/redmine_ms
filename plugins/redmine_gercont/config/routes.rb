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
  resources :plans
end

get 'sla_events', to: 'sla_events#index', as: 'sla_events'
get 'assessments', to: 'assessments#index', as: 'assessments'
post '/rules/:id/change_status', to: 'rules#change_status', as: 'rule_status'
put '/rules/:id/reorder', to: 'rules#reorder'
post '/sla/:id/change_status', to: 'slas#change_status', as: 'sla_status'
put 'update_assessments_by_issue', to: 'assessments#update_by_issue'
