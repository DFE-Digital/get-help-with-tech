require 'rails_helper'

RSpec.feature 'How to order devices', type: :feature do
  let(:devices_guidance_how_to_order_page) { PageObjects::DevicesGuidance::HowToOrderPage.new }

  scenario 'Visiting the How to order devices guidance' do
    visit devices_how_to_order_path

    expect(devices_guidance_how_to_order_page).to be_displayed

    expect(devices_guidance_how_to_order_page.page_heading).to have_content('How to order laptops and tablets during coronavirus (COVID-19)')
    expect(devices_guidance_how_to_order_page.steps.length).to equal(6)
  end
end
