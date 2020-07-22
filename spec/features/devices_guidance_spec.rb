require 'rails_helper'

RSpec.feature 'Devices guidance pages', type: :feature do
  scenario 'Index page' do
    visit '/devices'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.devices_guidance_index')
    expect(page).to have_selector 'a', text: I18n.t('devices_guidance.about_the_offer.title')
  end

  scenario 'Get help with technology: devices subpage' do
    visit '/devices/about-the-offer'

    expect(page).to have_selector 'h1', text: I18n.t!('devices_guidance.about_the_offer.title')
    expect(page).to have_selector 'a', text: I18n.t!('page_titles.devices_guidance_index')
  end

  scenario 'Non-existent page' do
    visit '/devices/non-existent-page'

    expect(page).to have_selector 'h1', text: 'Page not found'
  end
end
