Rails.application.routes.draw do
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  resources :vehicles do
    resources :service_records, only: %i[new create destroy], shallow: true
    resources :maintenance_schedules, only: %i[new create edit update destroy], shallow: true
    resources :renewals, only: %i[new create edit update destroy], shallow: true
  end
  resources :drivers
  resources :assignments, only: %i[new create edit update destroy]
  resources :alerts, only: %i[index destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "vehicles#index"
end
