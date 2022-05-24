require 'rails_helper'

RSpec.feature 'Site Info Banner', type: :feature do
  context 'Default no site info banner message text present' do
    before do
      allow(Site).to receive(:long_form_banner_message_flag?).and_return(false)
    end

    scenario 'User cannot see the site info banner on the home page' do
      visit root_path
      expect(page).to have_no_css('#site-info-banner-content')
    end
  end

  context 'Site info banner message text present' do
    before do
      allow(Site).to receive(:long_form_banner_message_flag?).and_return(true)
    end

    scenario 'User can see the site info banner on the home page' do
      visit root_path
      expect(page).to have_css('#site-info-banner-content')
    end
  end
end
