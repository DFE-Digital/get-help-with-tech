require 'rails_helper'

RSpec.feature 'How to order devices', type: :feature do
  let(:devices_guidance_how_to_order_page) { PageObjects::DevicesGuidance::HowToOrderPage.new }

  scenario 'Visiting the How to order devices guidance' do
    visit devices_how_to_order_path

    expect(devices_guidance_how_to_order_page).to be_displayed

    expect(devices_guidance_how_to_order_page.page_heading).to have_content('How to order DfE laptops and tablets')
    expect(devices_guidance_how_to_order_page.steps.length).to eq(4)
  end
end
