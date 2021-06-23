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
    then_i_see_that_ordering_is_closed
    when_i_click_continue
    then_i_see_a_privacy_notice
    when_i_click_continue
    then_i_see_the_la_funded_places_homepage
  end

  scenario 'step through the wizard as the first user for a school' do
    given_my_school_has_an_unavailable_allocation
    as_a_new_school_user
    when_i_sign_in_for_the_first_time
    then_i_see_a_welcome_page_for_my_school
    when_i_click_continue
    then_i_see_a_privacy_notice
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
    then_i_see_the_organisation_page
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

  def as_a_new_school_user
    @user = create(:school_user, :new_visitor, :has_not_seen_privacy_notice, school: school, orders_devices: true)
  end

  def as_a_new_la_funded_user
    @school = create(:iss_provision, std_device_allocation: available_allocation)
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

  def then_i_see_that_ordering_is_closed
    expect(page).to have_text('Ordering is now closed')
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

  def then_i_see_a_privacy_notice
    expect(page).to have_text('Privacy notice')
  end

  def then_i_see_the_organisation_page
    expect(page).to have_text 'Your account'
  end

  def when_i_sign_out
    sign_out
  end

  def and_then_sign_in_again
    visit validate_token_url_for(@user)
    click_on 'Continue'
  end
end
