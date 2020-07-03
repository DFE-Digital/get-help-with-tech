require 'rails_helper'

RSpec.feature 'Collecting mobile information guide pages', type: :feature do
  scenario 'First guide page should be an overview with a contents list' do
    visit '/collecting-mobile-info-guide'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.collecting_mobile_info_guide')
    expect(page).to have_selector 'h2', text: 'Contents'
    expect(page).to have_selector 'a', text: I18n.t('collecting_mobile_info_guide.asking_for_network')
    expect(page).to have_selector 'h2', text: I18n.t('collecting_mobile_info_guide.overview')
  end

  scenario 'Next and previous page should take you through guide' do
    visit '/collecting-mobile-info-guide'
    click_on('Next')
    expect(page).to have_selector 'h2', text: I18n.t('collecting_mobile_info_guide.asking_for_network')
    expect(page).not_to have_selector 'a', text: I18n.t('collecting_mobile_info_guide.asking_for_network')
    expect(page).to have_selector 'a', text: I18n.t('collecting_mobile_info_guide.overview')

    click_on('Previous')
    expect(page).to have_selector 'h2', text: I18n.t('collecting_mobile_info_guide.overview')
    expect(page).not_to have_selector 'a', text: I18n.t('collecting_mobile_info_guide.overview')
  end

  scenario 'Contents list takes you to any page in the guide' do
    visit '/collecting-mobile-info-guide'
    click_on(I18n.t('collecting_mobile_info_guide.privacy'))
    expect(page).to have_selector 'h2', text: I18n.t('collecting_mobile_info_guide.privacy')
  end
end
