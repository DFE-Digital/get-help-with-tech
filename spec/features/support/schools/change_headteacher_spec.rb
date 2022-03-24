require 'rails_helper'

RSpec.feature 'Updating school headteacher details', skip: true do
  let(:non_support_third_line_user) { create(:support_user) }
  let(:support_third_line_user) { create(:support_user, :third_line) }
  let(:school) { create(:school) }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:edit_page) { PageObjects::Support::School::Headteacher::EditPage.new }

  scenario 'non support third line users cant change a school headteacher details' do
    sign_in_as non_support_third_line_user

    visit support_school_path(school.urn)
    expect_no_headteacher_change_link
  end

  scenario 'headteacher with invalid details' do
    sign_in_as support_third_line_user

    visit support_school_path(school.urn)
    go_to_edit_headteacher(school.name)

    expect(edit_page.email_address_field.value).to be_blank

    click_on('Set as headteacher')
    expect_email_invalid_error(school.name)
  end

  scenario 'modify details of an existing headteacher' do
    school = create(:school, :with_headteacher)
    headteacher = school.headteacher
    new_email = 'headteacher@example.com'

    sign_in_as support_third_line_user

    visit support_school_path(school.urn)
    go_to_edit_headteacher(school.name)

    expect(edit_page.title_field.value).to eq(headteacher.title)
    expect(edit_page.full_name_field.value).to eq(headteacher.full_name)
    expect(edit_page.email_address_field.value).to eq(headteacher.email_address)
    expect(edit_page.phone_number_field.value).to eq(headteacher.phone_number)
    expect(edit_page.submit_button.text).to eq('Update')

    fill_in('Email address', with: new_email)
    click_on('Update')

    expect_headteacher_changed_banner(school.name)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: new_email)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: headteacher.full_name)
    expect(school_page.school_details['Headteacher']).to have_action_element(text: 'Change headteacher')
  end

  scenario 'set existing contact as headteacher' do
    school = create(:school)
    contact = create(:school_contact, :contact, school: school)
    new_email = 'headteacher@example.com'

    sign_in_as support_third_line_user

    visit support_school_path(school.urn)
    go_to_edit_headteacher(school.name)

    expect(edit_page.title_field.value).to eq(contact.title)
    expect(edit_page.full_name_field.value).to eq(contact.full_name)
    expect(edit_page.email_address_field.value).to eq(contact.email_address)
    expect(edit_page.phone_number_field.value).to eq(contact.phone_number)
    expect(edit_page.submit_button.text).to eq('Set as headteacher')

    fill_in('Email address', with: 'headteacher@example.com')
    click_on('Set as headteacher')

    expect_headteacher_changed_banner(school.name)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: new_email)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: contact.full_name)
    expect(school_page.school_details['Headteacher']).to have_action_element(text: 'Change headteacher')
  end

  scenario 'create a new headteacher contact' do
    title = 'Mr.'
    full_name = 'New Headteacher Name'
    email = 'headteacher@example.com'
    phone_number = '07759337788'

    sign_in_as support_third_line_user

    visit support_school_path(school.urn)
    go_to_edit_headteacher(school.name)

    expect(edit_page.title_field.value).to be_blank
    expect(edit_page.full_name_field.value).to be_blank
    expect(edit_page.email_address_field.value).to be_blank
    expect(edit_page.phone_number_field.value).to be_blank
    expect(edit_page.submit_button.text).to eq('Set as headteacher')

    fill_in('Title', with: title)
    fill_in('Full name', with: full_name)
    fill_in('Email address', with: email)
    fill_in('Telephone number', with: phone_number)
    click_on('Set as headteacher')

    expect_headteacher_changed_banner(school.name)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: title)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: full_name)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: email)
    expect(school_page.school_details['Headteacher']).to have_value_element(text: phone_number)
    expect(school_page.school_details['Headteacher']).to have_action_element(text: 'Change headteacher')
  end

private

  def expect_no_headteacher_change_link
    expect(school_page).to be_displayed
    expect(school_page.school_details['Headteacher']).to have_no_action_element
  end

  def expect_email_invalid_error(school_name)
    error_message = 'Enter an email address in the correct format, like name@example.com'
    expect(edit_page).to be_displayed
    expect(edit_page).to have_school_name_header(text: school_name)
    expect(edit_page).to have_error_summary(text: 'There is a problem')
    expect(edit_page).to have_no_email_address_field
    expect(edit_page).to have_email_address_error_message(text: error_message)
    expect(edit_page).to have_email_address_error_field
  end

  def expect_headteacher_changed_banner(school_name)
    expect_school_page_with_banner(:success, "#{school_name}'s headteacher details updated")
  end

  def expect_school_page_with_banner(type, text)
    expect(school_page).to be_displayed
    expect(page).to have_selector(".app-banner--#{type}", text: text)
  end

  def go_to_edit_headteacher(school_name)
    school_page.school_details['Headteacher'].follow_action_link
    expect(edit_page).to be_displayed
    expect(edit_page).to have_school_name_header(text: school_name)
    expect(edit_page).to have_title_label(text: 'Title')
    expect(edit_page).to have_title_field
    expect(edit_page).to have_full_name_label(text: 'Full name')
    expect(edit_page).to have_full_name_field
    expect(edit_page).to have_email_address_label(text: 'Email address')
    expect(edit_page).to have_email_address_field
    expect(edit_page).to have_phone_number_label(text: 'Telephone number')
    expect(edit_page).to have_phone_number_field
  end
end
