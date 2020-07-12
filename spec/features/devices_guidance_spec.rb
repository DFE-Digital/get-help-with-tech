require 'rails_helper'

RSpec.feature 'Devices guidance pages', type: :feature do
  scenario 'Get help with technology: devices subpage' do
    visit '/devices/get-help-with-technology-devices'

    expect(page).to have_selector 'h1', text: I18n.t!('devices_guidance.get_help_with_technology_devices.title')
  end
end
