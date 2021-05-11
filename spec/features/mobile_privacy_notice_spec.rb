require 'rails_helper'

RSpec.describe 'Display the mobile data privacy notice page', type: :feature do
  it 'Privacy notice is available via original location' do
    visit '/increasing-mobile-data/privacy-notice'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.increasing_mobile_data_privacy_notice')
  end

  it 'New shorter privacy url displays privacy notice' do
    visit '/mobile-privacy'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.increasing_mobile_data_privacy_notice')
  end
end
