require 'rails_helper'

RSpec.describe 'View pages', type: :feature do
  it 'Root URL should be the guidance page' do
    visit '/'
    expect(page).to have_selector 'h1', text: I18n.t('service_name')
  end

  it 'Navigate to guidance page' do
    visit '/pages/guidance'

    expect(page).to have_http_status(:ok)
    expect(page).to have_selector 'h1', text: I18n.t('service_name')
  end

  it 'view How to request 4G wireless routers' do
    visit '/how-to-request-4g-wireless-routers'

    expect(page).to have_http_status(:ok)
    expect(page).to have_selector 'h1', text: 'How to request 4G wireless routers'
  end

  routes = Rails.application.routes.routes.routes.filter { |r| r.defaults[:controller] == 'pages' }.map { |r| r.path.spec.to_s }
  routes.shift
  routes.map! { |r| r[0..-11] }

  routes.each do |route|
    it "viewing #{route}" do
      visit route

      expect(page).to have_http_status(:ok)
      expect(page).to have_selector 'h1'
    end
  end
end
