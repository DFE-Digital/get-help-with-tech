require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario 'Root URL should be the guidance page' do
    visit '/'
    expect(page).to have_selector 'h1', text: I18n.t('service_name')
  end

  scenario 'Navigate to guidance page' do
    visit '/pages/guidance'

    expect(page).to have_http_status(:ok)
    expect(page).to have_selector 'h1', text: I18n.t('service_name')
  end

  scenario 'view How to request 4G wireless routers' do
    visit '/how-to-request-4g-wireless-routers'

    expect(page).to have_http_status(:ok)
    expect(page).to have_selector 'h1', text: 'How to request 4G wireless routers'
  end
end
