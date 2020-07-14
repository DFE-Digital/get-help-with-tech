require 'rails_helper'

RSpec.feature 'Distributing BT vouchers to guide pages', type: :feature do
  scenario 'First guide page should be an overview with a contents list' do
    visit '/guide-for-distributing-bt-vouchers'
    expect(page).to have_selector 'h1', text: I18n.t('page_titles.guide_for_distributing_bt_vouchers')
    expect(page).to have_selector 'h2', text: 'Contents'
    expect(page).to have_selector 'a', text: I18n.t('guide_for_distributing_bt_vouchers.what_to_do_with_the_vouchers')
    expect(page).to have_selector 'h2', text: I18n.t('guide_for_distributing_bt_vouchers.overview')
  end

  scenario 'Next and previous page should take you through guide' do
    visit '/guide-to-collecting-mobile-information'
    click_on('Next')
    expect(page).to have_selector 'h2', text: I18n.t('guide_for_distributing_bt_vouchers.who_to_give_vouchers_to')
    expect(page).not_to have_selector 'a', text: I18n.t('guide_for_distributing_bt_vouchers.who_to_give_vouchers_to')
    expect(page).to have_selector 'a', text: I18n.t('guide_for_distributing_bt_vouchers.overview')

    click_on('Previous')
    expect(page).to have_selector 'h2', text: I18n.t('guide_for_distributing_bt_vouchers.overview')
    expect(page).not_to have_selector 'a', text: I18n.t('guide_for_distributing_bt_vouchers.overview')
  end

  scenario 'Contents list takes you to any page in the guide' do
    visit '/guide-to-collecting-mobile-information'
    click_on(I18n.t('guide_for_distributing_bt_vouchers.what_to_do_with_the_vouchers'))
    expect(page).to have_selector 'h2', text: I18n.t('guide_for_distributing_bt_vouchers.what_to_do_with_the_vouchers')
  end
end
