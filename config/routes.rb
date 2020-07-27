Rails.application.routes.draw do
  get '/start', to: 'pages#start'
  get '/about-bt-wifi', to: 'pages#about_bt_wifi'
  get '/about-increasing-mobile-data', to: 'pages#about_increasing_mobile_data'
  get '/bt-wifi/privacy-notice', to: 'pages#bt_wifi_privacy_notice'
  get '/bt-wifi/suggested-email-to-schools', to: 'pages#suggested_email_to_schools'
  get '/increasing-mobile-data/privacy-notice', to: 'pages#increasing_mobile_data_privacy_notice'
  get '/pages/guidance', to: redirect('/')

  get '/guide-to-collecting-mobile-information', to: 'guide_to_collecting_mobile_information#index'
  get '/guide-to-collecting-mobile-information/asking-for-account-holder', to: 'guide_to_collecting_mobile_information#asking_for_account_holder'
  get '/guide-to-collecting-mobile-information/asking-for-network', to: 'guide_to_collecting_mobile_information#asking_for_network'
  get '/guide-to-collecting-mobile-information/telling-about-offer', to: 'guide_to_collecting_mobile_information#telling_about_offer'
  get '/guide-to-collecting-mobile-information/privacy', to: 'guide_to_collecting_mobile_information#privacy'

  get '/guide-for-distributing-bt-vouchers', to: 'guide_for_distributing_bt_vouchers#index'
  get '/guide-for-distributing-bt-vouchers/who-to-give-vouchers-to', to: 'guide_for_distributing_bt_vouchers#who_to_give_vouchers_to'
  get '/guide-for-distributing-bt-vouchers/what-to-do-with-the-vouchers', to: 'guide_for_distributing_bt_vouchers#what_to_do_with_the_vouchers'
  get '/guide-for-distributing-bt-vouchers/not-offered-vouchers-yet', to: 'guide_for_distributing_bt_vouchers#not_offered_vouchers_yet'

  get '/devices', to: 'devices_guidance#index', as: :devices_guidance_index
  get '/devices/:subpage_slug', to: 'devices_guidance#subpage', as: :devices_guidance_subpage

  resources :sessions, only: %i[create destroy]
  resources :users, only: %i[new create]

  get '/token/validate', to: 'sign_in_tokens#validate', as: :validate_sign_in_token
  delete '/token/validate', to: 'sign_in_tokens#destroy', as: :destroy_sign_in_token
  get '/token/validate-manual', to: 'sign_in_tokens#validate_manual', as: :validate_manually_entered_sign_in_token
  get '/token/sent/:token', to: 'sign_in_tokens#sent', as: :sent_token
  get '/token/email-not-recognised', to: 'sign_in_tokens#email_not_recognised', as: :email_not_recognised

  namespace :mno do
    resources :extra_mobile_data_requests, only: %i[index show edit update], path: '/extra-mobile-data-requests' do
      put 'bulk-update', to: 'extra_mobile_data_requests#bulk_update', on: :collection
      get 'report-a-problem', to: 'extra_mobile_data_requests#report_problem', as: :report_problem
    end
  end

  namespace :responsible_body, path: '/responsible-body' do
    get '/', to: 'home#show', as: :home
    resources :bt_wifi_vouchers, only: %i[index], path: '/bt-wifi-vouchers' do
      get 'download', to: 'bt_wifi_vouchers#download', on: :collection
    end
    resources :extra_mobile_data_requests, only: %i[index new create], path: '/extra-mobile-data-requests'
  end

  namespace :support do
    get '/', to: 'service_performance#index', as: :service_performance
  end

  get '/healthcheck', to: 'monitoring#healthcheck', as: :healthcheck

  get '/sign-in', to: 'sign_in_tokens#new', as: :sign_in
  post '/sign-in', to: 'sign_in_tokens#create'

  get '/403', to: 'errors#forbidden', via: :all
  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unprocessable_entity', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all

  get '/', to: 'pages#index', as: :guidance_page
end
