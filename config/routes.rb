Rails.application.routes.draw do
  get '/pages/:page', to: 'pages#show'

  resources :application_forms, :allocation_request_forms

  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unprocessable_entity', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all

  get '/', to: redirect('allocation_request_forms/new')
end
