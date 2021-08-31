require 'rails_helper'

RSpec.feature 'Mobile data privacy notice page redirects to general privacy notice', type: :feature do
  scenario 'visiting original location' do
    visit '/increasing-mobile-data/privacy-notice'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.general_privacy_notice')
  end

  scenario 'visiting shorter URL' do
    visit '/mobile-privacy'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.general_privacy_notice')
  end
end
