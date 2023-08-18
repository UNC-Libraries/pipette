Pipette::Engine.routes.draw do
  get '/' => 'resources#index'
  resources :collecting_units, only: [:index, :new, :edit, :update, :create]
  resources :resources, only: [:index]
  post '/process_finding_aids', to: 'process_finding_aids#process_all_ead'
end
