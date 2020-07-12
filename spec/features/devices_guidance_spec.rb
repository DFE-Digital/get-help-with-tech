require 'rails_helper'

RSpec.feature 'Devices guidance pages', type: :feature do
  scenario 'Index page' do
    visit '/devices'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.devices_guidance_index')
    expect(page).to have_selector 'a', text: I18n.t('devices_guidance.get_help_with_technology_devices.title')
  end

  scenario 'Get help with technology: devices subpage' do
    visit '/devices/get-help-with-technology-devices'

    expect(page).to have_selector 'h1', text: I18n.t!('devices_guidance.get_help_with_technology_devices.title')
    expect(page).to have_selector 'a', text: I18n.t!('page_titles.devices_guidance_index')
  end
end
