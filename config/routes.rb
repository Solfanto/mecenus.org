Rails.application.routes.draw do
  mount_roboto
  devise_for :admin_users
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  get 'home', to: 'home#index'

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
  end

  get 'create', to: 'projects#new', as: 'new_project'
  post 'create', to: 'projects#create', as: 'create_project'
  get 'projects', to: 'projects#index', as: 'projects'
  # get 'projects(/:id)', to: 'projects#show', as: 'project'
  get 'projects/:name/edit', to: 'projects#edit', as: 'edit_project', constraints: { name: /[^\/]+/ }
  patch 'projects/:name', to: 'projects#update', constraints: { name: /[^\/]+/ }, as: 'update_project'
  get 'projects/:name/close', to: 'projects#close', as: 'close_project', constraints: { name: /[^\/]+/ }
  delete 'projects/:name', to: 'projects#destroy', constraints: { name: /[^\/]+/ }
  post 'projects/:name/reopen', to: 'projects#reopen', as: 'reopen_project', constraints: { name: /[^\/]+/ }
  post 'projects/:name/publish', to: 'projects#publish', as: 'publish_project', constraints: { name: /[^\/]+/ }

  get 'projects/:project_name/support', to: 'donations#new', as: 'new_donation', constraints: { project_name: /[^\/]+/ }
  post 'projects/:project_name/support', to: 'donations#create', as: 'donations', constraints: { project_name: /[^\/]+/ }
  patch 'projects/:project_name/support', to: 'donations#create', constraints: { project_name: /[^\/]+/ }
  get 'projects/:project_name/support/edit', to: 'donations#edit', as: 'edit_donation', constraints: { project_name: /[^\/]+/ }
  delete 'projects/:project_name/support', to: 'donations#cancel', as: 'donation', constraints: { project_name: /[^\/]+/ }
  post 'projects/:project_name/follow', to: 'projects#follow', as: 'follow', constraints: { project_name: /[^\/]+/ }
  post 'projects/:project_name/unfollow', to: 'projects#unfollow', as: 'unfollow', constraints: { project_name: /[^\/]+/ }
  get 'projects/:project_name/supporters', to: 'projects#sponsors', as: 'sponsors', constraints: { project_name: /[^\/]+/ }

  get 'projects/:project_name/updates', to: 'posts#index', as: 'project_posts', constraints: { project_name: /[^\/]+/ }
  get 'projects/:project_name/updates/new', to: 'posts#new', as: 'new_project_post', constraints: { project_name: /[^\/]+/ }
  post 'projects/:project_name/updates', to: 'posts#create', constraints: { project_name: /[^\/]+/ }
  get 'projects/:project_name/updates/:id/edit', to: 'posts#edit', as: 'edit_project_post', constraints: { project_name: /[^\/]+/ }
  get 'projects/:project_name/updates/:id', to: 'posts#show', as: 'project_post', constraints: { project_name: /[^\/]+/ }
  patch 'projects/:project_name/updates/:id', to: 'posts#update', constraints: { project_name: /[^\/]+/ }
  
  post 'payment', to: 'payments#create', as: 'payments'

  get 'donations', to: 'donations#index', as: 'donations_index'

  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  get 'profile', to: 'users#edit', as: 'profile'
  patch 'profile', to: 'users#update'
  get 'payment_settings', to: 'users#edit_payment_settings', as: 'payment_settings'
  get 'bank_account_settings', to: 'users#edit_bank_account_settings', as: 'bank_account_settings'
  put 'bank_account_settings', to: 'users#update_bank_account_settings'
  get 'messages', to: 'messages#index', as: 'messages'
  get 'help', to: 'welcome#help', as: 'help'
  get 'guidelines', to: 'welcome#guidelines', as: 'guidelines'
  get 'terms', to: 'welcome#terms', as: 'terms'
  get 'contribute', to: 'welcome#contribute', as: 'contribute'
  get 'about', to: 'welcome#about', as: 'about'

  get 'search', to: 'search#index', as: 'search'

  get ':name', to: 'projects#show', as: 'project', constraints: { name: /[^\/]+/ }
end
