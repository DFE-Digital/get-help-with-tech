Rails.application.routes.draw do
  get '/pages/:guidance', to: 'pages#guidance'

  resources :application_forms do
    get 'success/:application_form_id', to: 'application_forms#success', as: :success
  end
  resources :allocation_request_forms do
    get 'success', to: 'allocation_request_forms#success'
  end

  resources :sessions, only: %i[create destroy]

  resources :sign_in_tokens, only: %i[new create]
  get '/token/validate/:token/:identifier', to: 'sign_in_tokens#validate', as: :validate_sign_in_token
  get '/token/manual', to: 'sign_in_tokens#manual', as: :validate_manually_entered_sign_in_token

  namespace :mno do
    resources :recipients, only: %i[index show edit update] do
      put 'bulk_update', to: 'recipients#bulk_update', on: :collection
      get 'report_problem', to: 'recipients#report_problem', as: :report_problem
    end
  end

  get '/sign_in', to: 'sign_in_tokens#new', as: :sign_in

  get '/403', to: 'errors#forbidden', via: :all
  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unprocessable_entity', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all

  get '/', to: redirect('pages/guidance')
end
