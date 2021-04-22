require 'rails_helper'

RSpec.feature 'Navigate school welcome wizard' do
  let(:available_allocation) { create(:school_device_allocation, :with_std_allocation, allocation: 100, cap: 50) }
  let(:unavailable_allocation) { create(:school_device_allocation, :with_std_allocation) }
  let(:school_with_unavailable_allocation) { create(:school, :with_preorder_information, std_device_allocation: unavailable_allocation) }
  let(:school_with_available_allocation) { create(:school, :with_preorder_information, std_device_allocation: available_allocation) }
  let(:school) { @school }

  before do
    allow(Gsuite).to receive(:is_gsuite_domain?).and_return(true)
  end

  scenario 'step through wizard as LA Funded Place' do
    as_a_new_la_funded_user
    when_i_sign_in_for_the_first_time
    then_i_see_the_state_funded_interstitial
    when_i_click_continue
    then_i_see_privacy_policy
    when_i_click_continue
    then_i_see_the_la_funded_places_homepage
  end

  scenario 'step through the wizard as the first user for a school that has available allocation' do
    given_my_school_has_an_available_allocation
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_click_continue
    then_i_see_the_allocation_for_my_school

    when_i_click_continue
    then_i_see_the_techsource_account_page
  end

  scenario 'step through the wizard as the first user for a school' do
    given_my_school_has_an_unavailable_allocation
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_click_continue
    then_i_see_the_allocation_for_my_school

    when_i_click_continue
    then_i_see_the_techsource_account_page

    when_i_click_continue
    then_i_see_the_will_other_order_page

    when_i_choose_yes_and_submit_the_form
    then_i_see_information_about_devices_i_can_order

    when_i_click_continue
    then_im_asked_whether_my_school_will_order_chromebooks

    when_i_choose_yes_and_submit_the_chromebooks_form
    then_i_see_information_about_what_happens_next

    when_i_click_to_finish_and_go_to_homepage
    then_i_see_the_school_home_page
  end

  scenario 'step through wizard as subsequent user when the chromebooks question has been answered yes/no' do
    given_my_school_has_an_unavailable_allocation
    as_a_subsequent_school_user
    when_the_chromebooks_question_has_already_been_answered
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_click_continue
    then_i_see_the_allocation_for_my_school

    when_i_click_continue
    then_i_see_information_about_devices_i_can_order

    when_i_click_continue
    then_i_see_information_about_what_happens_next

    when_i_click_to_finish_and_go_to_homepage
    then_i_see_the_school_home_page
  end

  scenario 'step through wizard as subsequent user when the chromebooks question has not been answered yes/no' do
    given_my_school_has_an_unavailable_allocation
    as_a_subsequent_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_click_continue
    then_i_see_the_allocation_for_my_school

    when_i_click_continue
    then_i_see_information_about_devices_i_can_order

    when_i_click_continue
    then_im_asked_whether_my_school_will_order_chromebooks

    when_i_choose_no_and_submit_the_chromebooks_form
    then_i_see_information_about_what_happens_next

    when_i_click_to_finish_and_go_to_homepage
    then_i_see_the_school_home_page
  end

  scenario 'filling in invalid chromebook information' do
    given_my_school_has_an_unavailable_allocation
    as_a_subsequent_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_click_continue
    then_i_see_the_allocation_for_my_school

    when_i_click_continue
    then_i_see_information_about_devices_i_can_order

    when_i_click_continue
    then_im_asked_whether_my_school_will_order_chromebooks

    when_i_choose_yes_and_submit_invalid_chromebooks_information
    then_i_see_appropriate_error_messages

    when_i_provide_valid_chromebooks_information
    then_i_see_information_about_what_happens_next

    when_i_click_to_finish_and_go_to_homepage
    then_i_see_the_school_home_page
  end

  scenario 'the wizard resumes where left off' do
    given_my_school_has_an_unavailable_allocation
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school

    when_i_click_continue
    then_i_see_a_privacy_notice

    when_i_sign_out
    and_then_sign_in_again
    then_i_see_a_privacy_notice
  end

  def given_my_school_has_an_unavailable_allocation
    @school = school_with_unavailable_allocation
  end

  def given_my_school_has_an_available_allocation
    @school = school_with_available_allocation
  end

  def as_a_new_school_user
    @user = create(:school_user, :new_visitor, :has_not_seen_privacy_notice, school: school, orders_devices: true)
  end

  def as_a_new_la_funded_user
    @school = create(:la_funded_place, std_device_allocation: available_allocation)
    @user = create(:la_funded_place_user, :new_visitor, :has_not_seen_privacy_notice, school: @school)
  end

  def as_a_subsequent_school_user
    @user = create_list(:school_user, 2, :new_visitor, :has_not_seen_privacy_notice, school: school).last
  end

  def when_the_chromebooks_question_has_already_been_answered
    school.preorder_information.update!(will_need_chromebooks: 'no')
  end

  def when_i_sign_in_for_the_first_time
    visit validate_token_url_for(@user)
  end

  def then_i_see_the_state_funded_interstitial
    expect(page).to have_text('Get laptops and internet access for state-funded pupils at independent settings')
  end

  def then_i_see_privacy_policy
    expect(page).to have_text('Before you continue, please read the privacy notice.')
  end

  def then_i_see_the_la_funded_places_homepage
    expect(page).to have_selector('h1', text: 'Get laptops and internet access')
  end

  def then_i_see_a_welcome_page_for_my_school
    expect(page).to have_text("You’re signed in as #{school.name}")
  end

  def when_i_click_continue
    click_on 'Continue'
  end

  def when_i_click_to_finish_and_go_to_homepage
    click_on 'Finish and go to homepage'
  end

  def then_i_see_a_privacy_notice
    expect(page).to have_current_path(privacy_notice_path)
    expect(page).to have_text('Privacy notice')
  end

  def then_i_see_the_allocation_for_my_school
    heading = I18n.t('page_titles.school_user_welcome_wizard.allocation.title', allocation: device_allocation)
    expect(page).to have_text(heading)
  end

  def then_i_see_the_school_home_page
    expect(page).to have_current_path(home_school_path(urn: @user.school.urn))
    expect(page).to have_text(school.name)
  end

  def then_i_see_the_techsource_account_page
    expect(page).to have_current_path(welcome_wizard_techsource_account_school_path(urn: @user.school.urn))
    expect(page).to have_text('Use the TechSource website to place orders')
  end

  def then_i_see_the_will_other_order_page
    expect(page).to have_current_path(welcome_wizard_will_other_order_school_path(urn: @user.school.urn))
    expect(page).to have_text('You can invite someone else to order')
  end

  def when_i_choose_yes_and_submit_the_form
    choose 'Yes, I need to add someone'
    within('#school-welcome-wizard-invite-user-yes-conditional') do
      fill_in 'Name', with: 'Amanda Handstand'
      fill_in 'Email address', with: 'amanda@example.com'
      fill_in 'Telephone number', with: '01234 567890'
      choose 'Yes, give them access to the TechSource website'
    end
    click_on 'Continue'
  end

  def then_i_see_information_about_devices_i_can_order
    expect(page).to have_current_path(welcome_wizard_devices_you_can_order_school_path(urn: @user.school.urn))
    expect(page).to have_text('You can order different types of laptops')
  end

  def then_im_asked_whether_my_school_will_order_chromebooks
    expect(page).to have_current_path(welcome_wizard_chromebooks_school_path(urn: @user.school.urn))
    expect(page).to have_text('Will the school need Chromebooks?')
  end

  def when_i_choose_yes_and_submit_the_chromebooks_form
    choose 'Yes, we will need Chromebooks'
    within('#school-welcome-wizard-will-need-chromebooks-yes-conditional') do
      fill_in "School or #{school.responsible_body.humanized_type} email domain registered for G Suite for Education", with: 'example.com'
      fill_in 'Recovery email address', with: 'admin@trust.com'
    end
    click_on 'Continue'
  end

  def when_i_choose_yes_and_submit_invalid_chromebooks_information
    choose 'Yes, we will need Chromebooks'
    within('#school-welcome-wizard-will-need-chromebooks-yes-conditional') do
      fill_in "School or #{school.responsible_body.humanized_type} email domain registered for G Suite for Education", with: ''
      fill_in 'Recovery email address', with: ''
    end
    click_on 'Continue'
  end

  def when_i_provide_valid_chromebooks_information
    within('#school-welcome-wizard-will-need-chromebooks-yes-conditional') do
      fill_in "School or #{school.responsible_body.humanized_type} email domain registered for G Suite for Education", with: 'example.com'
      fill_in 'Recovery email address', with: 'admin@trust.com'
    end
    click_on 'Continue'
  end

  def then_i_see_appropriate_error_messages
    expect(page).to have_text 'Enter an email domain registered for G Suite for Education, like myschool.org.uk'
    expect(page).to have_text 'Enter an email address in the correct format, like name@example.com'
  end

  def when_i_choose_no_and_submit_the_chromebooks_form
    choose 'No, we do not need Chromebooks'
    click_on 'Continue'
  end

  def then_i_see_information_about_what_happens_next
    expect(page).to have_current_path(welcome_wizard_what_happens_next_school_path(urn: school.urn))
    expect(page).to have_text('check how many devices you can order')
  end

  def when_i_choose_yes_and_click_continue
    choose 'Yes, I will order devices'
    click_on 'Continue'
  end

  def when_i_sign_out
    sign_out
  end

  def and_then_sign_in_again
    visit validate_token_url_for(@user)
    click_on 'Continue'
  end

  def device_allocation
    school.std_device_allocation&.allocation || 0
  end
end
