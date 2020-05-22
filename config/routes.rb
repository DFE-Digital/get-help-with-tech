Rails.application.routes.draw do
  get '/pages/:page', to: 'pages#show'

  resources :application_forms do
    get 'success', to: 'application_forms#success'
  end
  resources :allocation_request_forms do
    get 'success', to: 'allocation_request_forms#success'
  end

  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unprocessable_entity', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all

  get '/', to: redirect('allocation_request_forms/new')
end
