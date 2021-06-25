require Rails.root.join('lib/constraints/require_dfe_user_constraint')

Rails.application.routes.draw do
  root 'pages#home_page'

  resource :notify_callbacks, only: [:create]

  get '/guides-for-parents-carers-and-students', to: 'guides_for_parents_carers_students#index'
  get '/digital-platforms', to: 'landing_pages#digital_platforms', as: :digital_platforms_landing_page
  get '/EdTech-demonstrator-programme', to: 'landing_pages#edtech_demonstrator_programme', as: :edtech_demonstrator_programme_landing_page

  get '/about-bt-wifi', to: redirect('/internet-access#bt-wifi')
  get '/about-increasing-mobile-data', to: redirect('/internet-access')
  get '/increasing-mobile-data/privacy-notice', to: 'pages#increasing_mobile_data_privacy_notice'
  get '/accessibility', to: 'pages#accessibility'
  get '/privacy', to: 'pages#privacy'
  get '/privacy/dfe-windows-privacy-notice', to: 'pages#dfe_windows_privacy_notice'
  get '/privacy/general-privacy-notice', to: 'pages#general_privacy_notice'
  get '/privacy/computers-for-kids-privacy-notice', to: 'pages#computers_for_kids_privacy_notice'
  get '/mobile-privacy', to: redirect('/increasing-mobile-data/privacy-notice')
  get '/request-a-change', to: 'pages#request_a_change'
  get '/how-to-request-4g-wireless-routers', to: redirect('/internet-access')
  get '/choosing-help-with-internet-access', to: redirect('/internet-access')
  get '/what-to-do-if-you-cannot-get-laptops-tablets-or-internet-access-from-dfe', to: 'pages#what_to_do_if_you_cannot_get_laptops_tablets_or_internet_access_from_dfe'
  get '/how-to-access-the-get-help-with-technology-service', to: 'pages#how_to_access_the_get_help_with_technology_service'

  # redirects for moved guidance pages
  get '/pages/guidance', to: redirect('/')
  get '/start', to: redirect('/')
  get '/devices/choosing-devices', to: redirect('/devices/device-allocations')
  get '/devices/allocation-and-specification', to: redirect('/devices/device-allocations')
  get '/devices/distributing-devices', to: redirect('/devices/device-distribution-and-ownership')
  get '/devices/support-and-maintenance', to: redirect('/devices', status: 301)

  get '/huawei-router-password', to: 'huawei_router_passwords#new', as: 'huawei_router_password'

  get '/internet-access', to: 'pages#internet_access', as: :connectivity_home

  get '/guide-to-collecting-mobile-information', to: redirect('/internet-access')
  get '/guide-to-collecting-mobile-information/asking-for-account-holder', to: 'guide_to_collecting_mobile_information#asking_for_account_holder'
  get '/guide-to-collecting-mobile-information/asking-for-network', to: redirect('/internet-access')
  get '/guide-to-collecting-mobile-information/telling-about-offer', to: redirect('/internet-access')
  get '/guide-to-collecting-mobile-information/privacy', to: 'guide_to_collecting_mobile_information#privacy'

  get '/devices/guide-to-resetting-windows-laptops-and-tablets', to: 'guide_to_resetting_windows_laptops_and_tablets#index'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/get-local-admin-and-bios-passwords', to: 'guide_to_resetting_windows_laptops_and_tablets#get_local_admin_and_bios_passwords'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/before-you-start', to: 'guide_to_resetting_windows_laptops_and_tablets#before_you_start'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/get-local-admin-and-bios-passwords', to: 'guide_to_resetting_windows_laptops_and_tablets#get_local_admin_and_bios_passwords'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/reset-the-bios-password', to: 'guide_to_resetting_windows_laptops_and_tablets#reset_the_bios_password'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/unlock-recovery-mode', to: 'guide_to_resetting_windows_laptops_and_tablets#unlock_recovery_mode'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/reset-the-device', to: 'guide_to_resetting_windows_laptops_and_tablets#reset_the_device'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/apply-your-own-settings', to: 'guide_to_resetting_windows_laptops_and_tablets#apply_your_own_settings'
  get '/devices/guide-to-resetting-windows-laptops-and-tablets/additional-support', to: 'guide_to_resetting_windows_laptops_and_tablets#additional_support'

  get '/devices', to: 'devices_guidance#index', as: :devices_guidance_index
  get '/devices/how-to-order', to: redirect('/devices')
  get '/devices/how-to-order-laptops-for-social-care-leavers', to: redirect('/devices')
  get '/devices/how-to-order-laptops-for-independent-special-schools', to: redirect('/devices')
  get '/devices/:subpage_slug', to: 'devices_guidance#subpage', as: :devices_guidance_subpage

  get '/cookie-preferences', to: 'cookie_preferences#new', as: 'cookie_preferences'
  post '/cookie-preferences', to: 'cookie_preferences#create', as: 'create_cookie_preferences'

  resources :sessions, only: %i[create destroy]

  namespace :support_ticket, path: '/get-support' do
    get '/', to: 'base#start'
    get '/describe-yourself', to: 'describe_yourself#new'
    post '/describe-yourself', to: 'describe_yourself#save'
    get '/school-details', to: 'school_details#new'
    post '/school-details', to: 'school_details#save'
    get '/academy-details', to: 'academy_details#new'
    post '/academy-details', to: 'academy_details#save'
    get '/local-authority-details', to: 'local_authority_details#new'
    post '/local-authority-details', to: 'local_authority_details#save'
    get '/college-details', to: 'college_details#new'
    post '/college-details', to: 'college_details#save'
    get '/contact-details', to: 'contact_details#new'
    post '/contact-details', to: 'contact_details#save'
    get '/support-needs', to: 'support_needs#new'
    post '/support-needs', to: 'support_needs#save'
    get '/support-details', to: 'support_details#new'
    post '/support-details', to: 'support_details#save'
    get '/check-your-request', to: 'check_your_request#new'
    post '/check-your-request', to: 'check_your_request#save'

    get '/parent-support', to: 'base#parent_support'
    get '/thank-you', to: 'base#thank_you'
  end

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
    resources :extra_mobile_data_requests_csv_update, only: %i[new create], path: '/extra-mobile-data-requests-csv-update'
  end

  namespace :responsible_body, path: '/responsible-body' do
    get '/', to: 'home#show', as: :home
    get '/privacy-notice', to: 'home#privacy_notice', as: :privacy_notice
    post '/privacy-notice', to: 'home#seen_privacy_notice'

    namespace :devices do
      get '/', to: 'home#show'
      get '/tell-us', to: 'home#tell_us'
      get '/who-will-order', to: 'who_will_order#show'
      get '/who-will-order/edit', to: 'who_will_order#edit'
      patch '/who-will-order', to: 'who_will_order#update'
      get 'order-devices', to: 'orders#show', as: :order_devices

      resources :schools, only: %i[index show update], param: :urn do
        get '/who-to-contact', to: 'who_to_contact#new'
        post '/who-to-contact', to: 'who_to_contact#create'
        put '/who-to-contact', to: 'who_to_contact#update'
        get '/who-to-contact/edit', to: 'who_to_contact#edit'
        get '/change-who-will-order', to: 'change_who_will_order#edit'
        patch '/change-who-will-order', to: 'change_who_will_order#update'
        member do
          get 'order-devices'
        end
      end
    end

    namespace :donated_devices, path: '/donated-devices' do
      get '/interest', to: 'interest#new'
      post '/interest', to: 'interest#create'

      get '/about-devices', to: 'interest#about'
      get '/queue', to: 'interest#queue'
      get '/interest-confirmation', to: 'interest#interest_confirmation'
      post '/interest-confirmation', to: 'interest#interest_confirmation'
      get '/all-or-some-schools', to: 'interest#all_or_some_schools'
      post '/all-or-some-schools', to: 'interest#all_or_some_schools'
      get '/select-schools', to: 'interest#select_schools'
      post '/select-schools', to: 'interest#select_schools'

      get '/what-devices-do-you-want', to: 'interest#device_types'
      post '/what-devices-do-you-want', to: 'interest#device_types'
      get '/how-many-devices', to: 'interest#how_many_devices'
      post '/how-many-devices', to: 'interest#how_many_devices'
      get '/address', to: 'interest#address'
      get '/disclaimer', to: 'interest#disclaimer'
      get '/check-answers', to: 'interest#check_answers'
      post '/check-answers', to: 'interest#check_answers'
      get '/opted-in', to: 'interest#opted_in'
    end

    namespace :internet do
      get '/', to: 'home#show'

      namespace :mobile, path: '/mobile' do
        get '/', to: 'extra_data_requests#guidance', as: :extra_data_guidance
        get '/requests', to: 'extra_data_requests#index', as: :extra_data_requests
        get '/requests/:id', to: 'extra_data_requests#show', as: :extra_data_request
        get '/type', to: 'extra_data_requests#new', as: :extra_data_requests_type
      end
    end
    resources :users
    namespace :devices do
      resources :schools, only: %i[index show], param: :urn do
        get '/chromebooks/edit', to: 'chromebook_information#edit'
        patch '/chromebooks', to: 'chromebook_information#update'
      end
    end
  end

  resources :schools, only: %i[index], param: :urn do
    member do
      get '/', to: 'school/home#show', as: :home
      get '/before-you-can-order', to: 'school/before_can_order#edit'
      patch '/before-you-can-order', to: 'school/before_can_order#update'
      get '/order-devices', to: 'school/devices#order'
      get '/details', to: 'school/details#show', as: :details
      get '/chromebooks/edit', to: 'school/chromebooks#edit'
      patch '/chromebooks', to: 'school/chromebooks#update'
      get '/welcome', to: 'school/welcome_wizard#welcome', as: :welcome_wizard_welcome
      get '/privacy', to: 'school/welcome_wizard#privacy', as: :welcome_wizard_privacy
      get '/allocation', to: 'school/welcome_wizard#allocation', as: :welcome_wizard_allocation
      get '/techsource-account', to: 'school/welcome_wizard#techsource_account', as: :welcome_wizard_techsource_account
      get '/will-other-order', to: 'school/welcome_wizard#will_other_order', as: :welcome_wizard_will_other_order
      get '/devices-you-can-order', to: 'school/welcome_wizard#devices_you_can_order', as: :welcome_wizard_devices_you_can_order
      get '/chromebooks', to: 'school/welcome_wizard#chromebooks', as: :welcome_wizard_chromebooks
      get '/what-happens-next', to: 'school/welcome_wizard#what_happens_next', as: :welcome_wizard_what_happens_next
      patch '/next(/:step)', to: 'school/welcome_wizard#next_step', as: :welcome_wizard
      patch '/prev', to: 'school/welcome_wizard#previous_step', as: :welcome_wizard_previous
      get '/get-laptops', to: 'school/la_funded_places#show', as: :get_laptops
      get '/order-laptops', to: 'school/la_funded_places#order', as: :order_laptops
      get '/funded-pupils-chromebooks/edit', to: 'school/la_funded_places_chromebooks#edit', as: :funded_chromebooks
      patch '/funded-pupils-chromebooks', to: 'school/la_funded_places_chromebooks#update', as: :update_funded_chromebooks
      get '/laptop-types', to: 'school/la_funded_places#laptop_types', as: :laptop_types
      resources :users, as: 'school_users', only: %i[index new create edit update], module: 'school'

      scope module: :school do
        namespace :donated_devices, path: '/donated-devices' do
          get '/interest', to: 'interest#new'
          post '/interest', to: 'interest#create'

          get '/about-devices', to: 'interest#about'
          get '/queue', to: 'interest#queue'
          get '/interest-confirmation', to: 'interest#interest_confirmation'
          post '/interest-confirmation', to: 'interest#interest_confirmation'
          get '/what-devices-do-you-want', to: 'interest#device_types'
          post '/what-devices-do-you-want', to: 'interest#device_types'
          get '/how-many-devices', to: 'interest#how_many_devices'
          post '/how-many-devices', to: 'interest#how_many_devices'
          get '/address', to: 'interest#address'
          post '/address', to: 'interest#address'
          get '/disclaimer', to: 'interest#disclaimer'
          post '/disclaimer', to: 'interest#disclaimer'
          get '/check-answers', to: 'interest#check_answers'
          post '/check-answers', to: 'interest#check_answers'
          get 'opted-in', to: 'interest#opted_in'
        end

        namespace :internet do
          get '/', to: 'home#show'

          namespace :mobile, path: '/mobile' do
            get '/', to: 'extra_data_requests#guidance', as: :extra_data_guidance
            get '/requests', to: 'extra_data_requests#index', as: :extra_data_requests
            get '/requests/:id', to: 'extra_data_requests#show', as: :extra_data_request
            get '/type', to: 'extra_data_requests#new', as: :extra_data_requests_type
          end
        end
      end
    end
  end

  namespace :support do
    get '/', to: 'home#show', as: :home
    resources :privileged_users, only: %i[index show destroy new create], path: 'privileged-users'
    get '/schools', to: 'home#schools'
    get '/technical', to: 'home#technical_support', as: :technical_support
    get '/feature-flags', to: 'home#feature_flags', as: :feature_flags
    get '/performance', to: 'service_performance#index', as: :service_performance
    resources :allocation_batch_jobs, only: %i[index show], path: 'allocation-batch-jobs' do
      member do
        post :send_notifications, path: 'send-notifications'
      end
    end
    get '/performance/mno-requests', to: 'service_performance#mno_requests', format: :csv
    get '/performance/remaining-device-counts', to: 'remaining_device_counts#index', format: :csv
    resource :impersonate, only: %i[create destroy]
    namespace :gias do
      get '/updates', to: 'home#index', as: :home
      resources :schools_to_add, only: %i[index show update], param: :urn, path: '/schools-to-add'
      resources :schools_to_close, only: %i[index show update], param: :urn, path: '/schools-to-close'
    end
    get '/zendesk-statistics', to: 'zendesk_statistics#index', as: :zendesk_statistics
    get '/zendesk-statistics/macros', to: 'zendesk_statistics#macros', as: :zendesk_macros
    resources :responsible_bodies, only: %i[index show], path: '/responsible-bodies' do
      resources :users, only: %i[new create], controller: 'users'
    end
    resources :schools, only: %i[show edit update], param: :urn do
      resource :addresses, only: %i[edit update], path: 'address'

      scope module: 'schools' do
        resource :opt_out, only: %i[edit update], path: 'opt-out'
      end

      collection do
        get 'search'
        get 'results'
        post 'results'

        get '/devices/enable-orders/for-many-schools', to: 'schools/devices/order_status#collect_urns_to_allow_many_schools_to_order'
        patch '/devices/enable-orders/for-many-schools', to: 'schools/devices/order_status#allow_ordering_for_many_schools', as: :allow_ordering_for_many_schools
      end

      get '/invite', to: 'schools#confirm_invitation', as: :confirm_invitation
      post '/invite', to: 'schools#invite'
      resources :users, only: %i[new create], controller: 'users'

      get '/history', to: 'schools#history', as: :history

      get '/devices/enable-orders', to: 'schools/devices/order_status#edit', as: :enable_orders
      get '/devices/enable-orders/confirm', to: 'schools/devices/order_status#confirm', as: :confirm_enable_orders
      patch '/devices/enable-orders', to: 'schools/devices/order_status#update'
      get '/devices/allocation/edit', to: 'schools/devices/allocation#edit'
      patch '/devices/allocation', to: 'schools/devices/allocation#update'
      get '/devices/chromebooks/edit', to: 'schools/devices/chromebooks#edit'
      patch '/devices/chromebooks', to: 'schools/devices/chromebooks#update'
      get '/devices/change-who-will-order', to: 'schools/devices/change_who_will_order#edit'
      patch '/devices/change-who-will-order', to: 'schools/devices/change_who_will_order#update'
    end

    namespace :performance_data, path: 'performance-data' do
      resources :schools, only: :index
    end

    resources :users, only: %i[show edit update destroy] do
      collection do
        get 'search'
        post 'results'
      end
      member do
        get 'confirm-deletion', to: 'users#confirm_destroy'
      end
      resources :schools, only: %i[index new create], controller: 'users/schools', param: :urn
      patch 'schools', to: 'users/schools#update_schools', as: :update_schools
      resource :responsible_body, only: %i[edit update], controller: 'users/responsible_body', path: 'responsible-body'
    end
    resources :extra_mobile_data_requests, only: %i[index show], path: 'extra-mobile-data-requests'
    resources :email_audits, only: [:index], path: 'email-audits'
    mount Sidekiq::Web => '/sidekiq', constraints: RequireSupportUserConstraint.new, as: :sidekiq_admin
  end

  namespace :computacenter do
    get '/', to: 'home#show', as: :home
    get '/user-ledger', to: 'user_ledger#index', as: :user_ledger
    get '/chromebooks', to: 'chromebooks#index', as: :chromebooks
    get '/donated-device-requests', to: 'donated_device_requests#index', as: :donated_device_requests
    resources :schools, only: %i[index edit update], path: '/school-changes', as: :school_changes, controller: 'school_changes'
    resources :responsible_bodies, only: %i[index edit update], path: '/responsible-body-changes', as: :responsible_body_changes, controller: 'responsible_body_changes'
    get '/techsource', to: 'techsource#new'
    post '/techsource', to: 'techsource#create'
    get '/multi-domain-chromebooks', to: 'multi_domain_chromebooks#index', as: :multi_domain_chromebooks
    get '/multi-domain-chromebooks-iss-scl', to: 'multi_domain_chromebooks_iss_scl#index', as: :multi_domain_chromebooks_iss_scl
    resources :api_tokens, path: '/api-tokens'
    resources :school_device_allocations, only: %i[index], path: '/school-device-allocations' do
      put '/', to: 'school_device_allocations#bulk_update', on: :collection
    end
    namespace :api do
      post '/cap-usage/bulk-update', to: 'cap_usage#bulk_update'
    end
  end

  get '/healthcheck', to: 'monitoring#healthcheck', as: :healthcheck

  get '/sign-in', to: 'sign_in_tokens#new', as: :sign_in
  post '/sign-in', to: 'sign_in_tokens#create'

  get '/privacy-notice', to: 'privacy_notice#show'
  patch '/privacy-notice', to: 'privacy_notice#seen', as: :seen_privacy_notice

  get '/techsource-start', to: 'techsource_launcher#start'

  get '/403', to: 'errors#forbidden', via: :all
  get '/404', to: 'errors#not_found', via: :all
  get '/422', to: 'errors#unprocessable_entity', via: :all
  get '/500', to: 'errors#internal_server_error', via: :all
end
