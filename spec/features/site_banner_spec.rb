require 'rails_helper'

RSpec.feature 'Site Banner', type: :feature do
  context 'Default no site banner message text present' do
    scenario 'User cannot see the site banner on the home page' do
      visit root_path
      expect(page).to have_no_css('#site-banner-app-card')
    end

    scenario 'User cannot see the site banner on the device guidance page' do
      visit devices_guidance_index_path
      expect(page).to have_no_css('#site-banner-app-card')
    end
  end

  context 'Site banner message text present' do
    before do
      allow(Site).to receive(:banner_message).and_return('This is a test message')
    end

    scenario 'User can see the site banner on the home page' do
      visit root_path
      expect(page).to have_css('#site-banner-app-card')
    end

    scenario 'User can see the site banner on the device guidance page' do
      visit devices_guidance_index_path
      expect(page).to have_css('#site-banner-app-card')
    end
  end
end
