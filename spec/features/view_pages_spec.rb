require 'rails_helper'

RSpec.feature 'View pages', type: :feature do
  scenario 'Root URL should be the guidance page' do
    visit '/'
    expect(page).to have_text 'Improving children’s internet access'
  end

  scenario 'Navigate to guidance page' do
    visit '/pages/guidance'

    expect(page).to have_http_status(:ok)
    expect(page).to have_text 'Improving children’s internet access'
  end
end
