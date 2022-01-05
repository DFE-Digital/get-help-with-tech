require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario 'Root URL should be the guidance page' do
    visit '/'
    expect(page).to have_selector 'h1', text: I18n.t('service_name')
  end

  routes = Rails.application.routes.routes.routes.filter { |r| r.defaults[:controller] == 'pages' }.map { |r| r.path.spec.to_s }
  routes.shift
  routes.map! { |r| r[0..-11] }

  routes.each do |route|
    scenario "viewing #{route}" do
      visit route

      expect(page).to have_http_status(:ok)
      expect(page).to have_selector 'h1'
    end
  end
end
