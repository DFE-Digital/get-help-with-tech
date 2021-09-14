require 'rails_helper'

RSpec.feature 'Ordering for LA-funded devices', type: :feature, skip: 'Disabled for 30 Jun 2021 service closure' do
  before do
    given_there_is_an_independent_settings_school
    given_i_am_signed_in_as_an_independent_settings_school_user
    given_i_am_on_the_independent_settings_school_page
  end

  context 'when laptops are available' do
    before { given_i_have_not_ordered_all_my_laptops }

    scenario 'ordering laptops when I need Chromebooks' do
      when_i_navigate_to_school_order_page
      then_i_see_i_have_laptops_remaining
      when_i_click_on_continue
      then_i_am_asked_whether_i_need_chromebooks
      when_i_answer_yes
      when_i_click_on_continue
      then_i_see_the_how_to_order_page
      then_i_see_the_confirmation_i_will_order_chromebooks
      then_i_see_the_delivery_address
      then_i_see_how_to_sign_in_to_techsource
    end

    scenario 'ordering laptops when I do not need Chromebooks' do
      when_i_navigate_to_school_order_page
      then_i_see_i_have_laptops_remaining
      when_i_click_on_continue
      then_i_am_asked_whether_i_need_chromebooks
      when_i_answer_no
      when_i_click_on_continue
      then_i_see_the_how_to_order_page
      then_i_see_the_confirmation_i_will_not_order_chromebooks
      then_i_see_the_delivery_address
      then_i_see_how_to_sign_in_to_techsource
    end

    scenario 'ordering laptops when I am not sure I need Chromebooks' do
      when_i_navigate_to_school_order_page
      then_i_see_i_have_laptops_remaining
      when_i_click_on_continue
      then_i_am_asked_whether_i_need_chromebooks
      when_i_answer_im_not_sure
      when_i_click_on_continue
      then_i_see_the_how_to_order_page
      then_i_see_confirmation_i_have_not_indicated_whether_i_will_order_chromebooks
      then_i_see_the_delivery_address
      then_i_see_how_to_sign_in_to_techsource
    end

    scenario 'ordering laptops when a choice has already been made on Chromebooks' do
      given_i_have_already_confirmed_that_i_will_order_chromebooks
      when_i_navigate_to_school_order_page
      then_i_see_i_have_laptops_remaining
      when_i_click_on_continue
      then_i_see_the_how_to_order_page
      then_i_see_the_confirmation_i_will_order_chromebooks
      then_i_see_the_delivery_address
      then_i_see_how_to_sign_in_to_techsource
    end

    scenario 'ordering laptops when I previously was not sure I needed Chromebooks' do
      given_i_have_already_answered_that_i_was_not_sure_that_i_will_order_chromebooks
      when_i_navigate_to_school_order_page
      then_i_see_i_have_laptops_remaining
      when_i_click_on_continue
      then_i_see_the_how_to_order_page
      then_i_see_confirmation_i_have_not_indicated_whether_i_will_order_chromebooks
      then_i_see_the_delivery_address
      then_i_see_how_to_sign_in_to_techsource
    end
  end

  context 'when there are no laptops left to order' do
    before { given_i_have_ordered_all_of_my_laptops }

    scenario 'ordering laptops when no laptops left to order' do
      when_i_navigate_to_school_order_page
      then_i_see_i_have_no_laptops_remaining
    end
  end

  def given_there_is_an_independent_settings_school
    @school = create(:iss_provision, :can_order, :manages_orders)
  end

  def given_i_am_signed_in_as_an_independent_settings_school_user
    @user = create(:la_funded_place_user, :with_a_confirmed_techsource_account, :has_seen_privacy_notice, school: @school)
    sign_in_as(@user)
  end

  def given_i_am_on_the_independent_settings_school_page
    expect(page).to have_selector('h1', text: 'State-funded pupils in independent special schools and alternative provision Your account')
  end

  def given_i_have_already_confirmed_that_i_will_order_chromebooks
    @school.preorder_information.update!(will_need_chromebooks: 'yes')
  end

  def given_i_have_not_ordered_all_my_laptops
    @school.device_allocations.std_device.create!(allocation: 2, cap: 2, devices_ordered: 1)
  end

  def given_i_have_ordered_all_of_my_laptops
    @school.device_allocations.std_device.create!(allocation: 50, cap: 50, devices_ordered: 50)
  end

  def given_i_have_already_answered_that_i_was_not_sure_that_i_will_order_chromebooks
    @school.preorder_information.update!(will_need_chromebooks: 'i_dont_know')
  end

  def then_i_see_confirmation_i_have_not_indicated_whether_i_will_order_chromebooks
    expect(page).to have_text('not sure if you‘ll order Chromebooks')
  end

  def when_i_answer_no
    choose 'No, we will not order Chromebooks'
  end

  def when_i_answer_im_not_sure
    choose 'I’m not sure'
  end

  def then_i_see_the_how_to_order_page
    expect(page).to have_selector('h1', text: 'How to order')
  end

  def then_i_see_the_confirmation_i_will_not_order_chromebooks
    expect(page).to have_text('You have told us you will not order Chromebooks')
  end

  def when_i_click_on_continue
    click_on 'Continue'
  end

  def then_i_am_asked_whether_i_need_chromebooks
    expect(page).to have_selector('h1', text: 'Will your order include Google Chromebooks?')
  end

  def when_i_answer_yes
    choose 'Yes, we’ll order Chromebooks'
  end

  def then_i_see_the_confirmation_i_will_order_chromebooks
    expect(page).to have_text('You’ve told us you’ll order Chromebooks')
  end

  def then_i_see_the_delivery_address
    expect(@school.address_1).to be_present
    expect(page).to have_text(@school.address_1)
  end

  def then_i_see_how_to_sign_in_to_techsource
    expect(page).to have_selector('h2', text: 'How to sign in to TechSource for the first time')
    expect(page).to have_text("User ID: #{@user.email_address}")
    expect(page).to have_link('Start now')
  end

  def when_i_navigate_to_school_order_page
    visit order_devices_school_path(@school)
  end

  def then_i_see_i_have_laptops_remaining
    expect(page).to have_content('You’ve been allocated 2 laptops')
  end

  def then_i_see_i_have_no_laptops_remaining
    expect(page).to have_selector('h1', text: 'You’ve ordered all the devices you can')
    expect(page).to have_text('You’ve ordered 50 of 50 devices')
  end
end
