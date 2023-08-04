Pipette::Engine.routes.draw do
  get '/' => 'resources#index'
  resources :collecting_units, only: [:index, :new, :edit, :update, :create]
  resources :resources, only: [:index]
end
