require 'rails_helper'

RSpec.feature 'Submitting eligibility and BT hotspot information', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:responsible_body_home_page) { PageObjects::ResponsibleBody::HomePage.new }
  let(:allocation_request_form_page) { PageObjects::ResponsibleBody::AllocationRequestFormPage.new }

  before do
    given_i_am_signed_in_as_a_responsible_body_user
  end

  context 'for the first time' do
    scenario 'takes the user through the form, confirmation and back to the homepage' do
      given_the_responsible_body_has_no_eligibility_and_bt_hotspot_information
      when_i_visit_the_responsible_body_homepage
      then_step_1_is_shown_as_not_started_yet

      when_i_click_through_to_the_step_1_form
      and_i_submit_the_form
      then_i_see_an_error_summary

      when_i_correct_the_step_1_form_with_valid_data
      and_i_submit_the_form
      then_i_can_see_my_valid_data_and_am_prompted_to_check_my_answers

      when_i_submit_my_confirmation
      then_i_am_back_on_the_responsible_body_page
      and_i_can_see_the_valid_data_i_entered
      and_step_1_is_marked_as_completed
      and_there_is_only_one_allocation_request_in_the_db_with_the_valid_data
    end
  end

  context 'after the information has already been submitted' do
    scenario 'updates the info for the responsible body' do
      given_the_responsible_body_has_submitted_eligibility_and_bt_hotspot_information
      when_i_visit_the_responsible_body_homepage
      and_step_1_is_marked_as_completed

      when_i_click_through_to_the_step_1_form
      then_i_see_the_existing_data_in_the_form_fields

      when_i_fill_out_the_step_1_form_with_updated_data
      and_i_submit_the_form
      then_i_can_see_my_updated_data_and_am_prompted_to_check_my_answers

      when_i_submit_my_confirmation
      then_i_am_back_on_the_responsible_body_page
      and_i_can_see_the_updated_data_i_entered
      and_step_1_is_marked_as_completed
      and_there_is_only_one_allocation_request_in_the_db_with_the_updated_data
    end
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_the_responsible_body_has_no_eligibility_and_bt_hotspot_information
    expect(user.responsible_body.allocation_request).to be_nil
  end

  def when_i_visit_the_responsible_body_homepage
    visit responsible_body_home_path
    expect(page).to have_http_status(:ok)
  end

  def then_step_1_is_shown_as_not_started_yet
    expect(responsible_body_home_page.step_1_status.text).to eq('Not started yet')
  end

  def when_i_click_through_to_the_step_1_form
    click_on 'How many young people are eligible?'
    expect(allocation_request_form_page).to be_displayed
    expect(allocation_request_form_page.heading.text).to eq('How many young people are eligible?')
  end

  def when_i_correct_the_step_1_form_with_valid_data
    allocation_request_form_page.number_eligible_with_error.set '10'
    allocation_request_form_page.number_eligible_with_hotspot_access_with_error.set '5'
  end

  def and_i_submit_the_form
    allocation_request_form_page.continue_button.click
  end

  def then_i_see_an_error_summary
    expect(allocation_request_form_page.error_summary).to be_visible
    expect(allocation_request_form_page.error_summary.text).to include('The number of young people who are eligible must be a number between 0 and 10,000')
    expect(allocation_request_form_page.error_summary.text).to include('The number of those who can access a BT hotspot must be a number between 0 and 10,000')
  end

  def then_i_can_see_my_valid_data_and_am_prompted_to_check_my_answers
    expect(page).to have_css('h1', text: 'Check your answers')
    expect(page).to have_text('10')
    expect(page).to have_text('5')
  end

  def when_i_submit_my_confirmation
    click_on 'Submit'
  end

  def then_i_am_back_on_the_responsible_body_page
    expect(responsible_body_home_page).to be_displayed
  end

  def and_i_can_see_the_valid_data_i_entered
    expect(responsible_body_home_page.eligible_young_people.text).to eq('10')
    expect(responsible_body_home_page.number_who_can_see_a_bt_hotspot.text).to eq('5')
  end

  def and_step_1_is_marked_as_completed
    expect(responsible_body_home_page.step_1_status.text).to eq('Completed')
  end

  def and_there_is_only_one_allocation_request_in_the_db_with_the_valid_data
    allocation_request = user.responsible_body.reload.allocation_request
    expect(allocation_request).to be_present
    expect(allocation_request.number_eligible).to eq(10)
    expect(allocation_request.number_eligible_with_hotspot_access).to eq(5)
  end

  def given_the_responsible_body_has_submitted_eligibility_and_bt_hotspot_information
    create(:allocation_request,
      created_by_user: user,
      responsible_body: user.responsible_body,
      number_eligible: 13,
      number_eligible_with_hotspot_access: 10)
    expect(user.responsible_body.allocation_request).to be_present
  end

  def then_i_see_the_existing_data_in_the_form_fields
    expect(allocation_request_form_page.number_eligible.value).to eq("13")
    expect(allocation_request_form_page.number_eligible_with_hotspot_access.value).to eq("10")
  end

  def when_i_fill_out_the_step_1_form_with_updated_data
    allocation_request_form_page.number_eligible.set '10'
    allocation_request_form_page.number_eligible_with_hotspot_access.set '5'
  end

  def then_i_can_see_my_updated_data_and_am_prompted_to_check_my_answers
    expect(page).to have_css('h1', text: 'Check your answers')
    expect(page).to have_text('10')
    expect(page).to have_text('5')
  end

  def and_i_can_see_the_updated_data_i_entered
    expect(responsible_body_home_page.eligible_young_people.text).to eq('10')
    expect(responsible_body_home_page.number_who_can_see_a_bt_hotspot.text).to eq('5')
  end

  def and_there_is_only_one_allocation_request_in_the_db_with_the_updated_data
    allocation_request = user.responsible_body.reload.allocation_request
    expect(allocation_request).to be_present
    expect(allocation_request.number_eligible).to eq(10)
    expect(allocation_request.number_eligible_with_hotspot_access).to eq(5)
    expect(AllocationRequest.where(responsible_body: user.responsible_body).count).to eq(1)
  end
end
