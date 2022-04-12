require 'rails_helper'

RSpec.feature 'Create support ticket' do
  let(:school) { create(:school) }
  let(:contact_details_name) { 'John Doe' }
  let(:contact_details_email) { 'john.doe@example.com' }
  let(:contact_details_telephone_number) { '0123456789' }
  let(:support_details_message) { 'This is a test message' }
  let(:app) { PageObjects::SupportTicket::App.new }
  let(:get_support_page) { app.get_support }
  let(:describe_yourself_page) { app.describe_yourself }
  let(:school_details_page) { app.school_details }
  let(:contact_details_page) { app.contact_details }
  let(:support_needs_page) { app.support_needs }
  let(:support_details_page) { app.support_details }
  let(:check_your_request_page) { app.check_your_request }
  let(:thank_you_page) { app.thank_you }
  let(:start_the_form_journey_result) { app.load_school_details_page }

  context 'not signed in' do
    scenario 'school user can create a support ticket' do
      given_there_is_a_school

      when_i_visit_the_get_support_page
      and_i_click_the_start_now_button
      the_describe_yourself_page_is_displayed
      then_on_the_describe_yourself_page_i_select_that_i_work_for_a_school_or_trust
      and_on_the_describe_yourself_page_i_click_the_continue_button
      the_school_details_page_is_displayed
      then_on_the_school_details_page_i_enter_the_school_name_and_urn
      and_on_the_school_details_page_i_click_the_continue_button
      the_contact_details_page_is_displayed
      then_on_the_contact_details_page_i_enter_the_contact_details
      and_on_the_contact_details_page_i_click_the_continue_button
      the_support_needs_page_is_displayed
      then_on_the_support_needs_page_i_select_laptops
      and_on_the_support_needs_page_i_click_the_continue_button
      the_support_details_page_is_displayed
      then_on_the_support_details_page_i_enter_the_support_details
      and_on_the_support_details_page_i_click_the_continue_button
      the_check_your_request_page_is_displayed
      and_the_check_your_request_page_has_the_correct_details
      and_on_the_check_your_request_page_i_click_the_continue_button
      the_thank_you_page_is_displayed
      and_the_thank_you_page_has_the_confirmation_message
    end

    it 'creates a new SupportTicket record upon starting the journey' do
      expect { start_the_form_journey_result }.to change { SupportTicket.count }.by(1)
    end
  end

  def and_i_click_the_start_now_button
    get_support_page.start_now_button.click
  end

  def given_there_is_a_school
    school
  end

  def and_on_the_check_your_request_page_i_click_the_continue_button
    check_your_request_page.continue_button.click
  end

  def and_on_the_contact_details_page_i_click_the_continue_button
    contact_details_page.continue_button.click
  end

  def and_on_the_describe_yourself_page_i_click_the_continue_button
    describe_yourself_page.continue_button.click
  end

  def and_on_the_school_details_page_i_click_the_continue_button
    school_details_page.continue_button.click
  end

  def and_on_the_support_details_page_i_click_the_continue_button
    support_details_page.continue_button.click
  end

  def and_on_the_support_needs_page_i_click_the_continue_button
    support_needs_page.continue_button.click
  end

  def and_the_check_your_request_page_has_the_correct_details
    expect(check_your_request_page).to have_text "#{school.name} (URN: #{school.urn})"
    expect(check_your_request_page).to have_text contact_details_name
    expect(check_your_request_page).to have_text contact_details_email
    expect(check_your_request_page).to have_text contact_details_telephone_number
    expect(check_your_request_page).to have_text support_details_message
  end

  def and_the_thank_you_page_has_the_confirmation_message
    expect(thank_you_page).to have_text 'Support request sent'
  end

  def the_check_your_request_page_is_displayed
    expect(check_your_request_page).to be_displayed
  end

  def the_contact_details_page_is_displayed
    expect(contact_details_page).to be_displayed
  end

  def the_describe_yourself_page_is_displayed
    expect(describe_yourself_page).to be_displayed
  end

  def the_school_details_page_is_displayed
    expect(school_details_page).to be_displayed
  end

  def the_support_details_page_is_displayed
    expect(support_details_page).to be_displayed
  end

  def the_support_needs_page_is_displayed
    expect(support_needs_page).to be_displayed
  end

  def the_thank_you_page_is_displayed
    expect(thank_you_page).to be_displayed
  end

  def then_on_the_contact_details_page_i_enter_the_contact_details
    contact_details_page.your_full_name_field.set contact_details_name
    contact_details_page.your_email_address_field.set contact_details_email
    contact_details_page.telephone_number_field.set contact_details_telephone_number
  end

  def then_on_the_describe_yourself_page_i_select_that_i_work_for_a_school_or_trust
    describe_yourself_page.school_radio_button.click
  end

  def then_on_the_school_details_page_i_enter_the_school_name_and_urn
    school_details_page.school_name_field.set school.name
    school_details_page.school_urn_field.set school.urn
  end

  def then_on_the_support_details_page_i_enter_the_support_details
    support_details_page.message_field.set support_details_message
  end

  def then_on_the_support_needs_page_i_select_laptops
    support_needs_page.laptops_checkbox_option.click
  end

  def when_i_complete_the_support_ticket_form
    app.load_check_your_request_page
  end

  def when_i_visit_the_describe_yourself_page
    describe_yourself_page.load
  end

  def when_i_visit_the_get_support_page
    get_support_page.load
  end
end
