require 'rails_helper'

RSpec.describe 'Collecting mobile information guide pages', type: :feature do
  it 'First guide page should be an overview with a contents list' do
    visit '/guide-to-collecting-mobile-information'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.guide_to_collecting_mobile_information')
    expect(page).to have_selector 'h2', text: 'Contents'
    expect(page).to have_selector 'a', text: I18n.t('guide_to_collecting_mobile_information.asking_for_network')
    expect(page).to have_selector 'h2', text: I18n.t('guide_to_collecting_mobile_information.overview')
  end

  it 'Next and previous page should take you through guide' do
    visit '/guide-to-collecting-mobile-information'
    click_on('Next')
    expect(page).to have_selector 'h2', text: I18n.t('guide_to_collecting_mobile_information.asking_for_network')
    expect(page).not_to have_selector 'a', text: I18n.t('guide_to_collecting_mobile_information.asking_for_network')
    expect(page).to have_selector 'a', text: I18n.t('guide_to_collecting_mobile_information.overview')

    click_on('Previous')
    expect(page).to have_selector 'h2', text: I18n.t('guide_to_collecting_mobile_information.overview')
    expect(page).not_to have_selector 'a', text: I18n.t('guide_to_collecting_mobile_information.overview')
  end

  it 'Contents list takes you to any page in the guide' do
    visit '/guide-to-collecting-mobile-information'
    click_on(I18n.t('guide_to_collecting_mobile_information.privacy'))
    expect(page).to have_selector 'h2', text: I18n.t('guide_to_collecting_mobile_information.privacy')
  end
end
