# frozen_string_literal: true

Pipette::Engine.routes.draw do
  get '/' => 'resources#index'
  resources :collecting_units, only: [:index, :new, :edit, :update, :create]
  resources :resources, only: [:index]
  resources :job_status, only: [:index]
  post '/process_selected_finding_aids', to: 'process_finding_aids#process_selected_ead'
  post '/process_all_finding_aids', to: 'process_finding_aids#process_all_ead'
end
