require 'rails_helper'

RSpec.feature 'Devices guidance pages', type: :feature do
  scenario 'Get help with technology: devices subpage' do
    visit '/devices/about-the-offer'

    expect(page).to have_selector 'h1', text: I18n.t!('devices_guidance.about_the_offer.title')
  end

  scenario 'Non-existent page' do
    visit '/devices/non-existent-page'

    expect(page).to have_selector 'h1', text: 'Page not found'
  end

  scenario 'Images that NO longer exist' do
    visit '/devices/non-existent-image.png'

    expect(page.status_code).to be(404)
  end
end
