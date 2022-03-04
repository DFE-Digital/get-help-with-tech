require 'rails_helper'

RSpec.feature 'Inviting school users' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school, :manages_orders) }
  let(:other_school) { create(:school) }
  let(:school_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:new_school_user_page) { PageObjects::Support::Users::InviteNewUserPage.new }
  let(:existing_user) { create(:school_user, email_address: 'existinguser@example.com', schools: [other_school]) }

  before { stub_computacenter_outgoing_api_calls }

  scenario 'support invites new school user' do
    given_i_am_signed_in_as_a_support_user
    when_i_visit_the_school_page
    and_i_click_the_invite_a_new_user_button
    then_i_see_the_invite_a_new_school_user_page

    when_fill_in_invite_school_user_form
    and_i_submit_invite_school_user_form
    and_i_click_through_to_the_school_page
    then_i_see_the_user_on_the_school_page
    and_the_school_is_shown_as_contacted
  end

  scenario 'support invites user to a school who already exists on another school' do
    given_i_am_signed_in_as_a_support_user
    and_there_is_an_existing_user_on_another_school
    when_i_visit_the_school_page
    and_i_click_the_invite_a_new_user_button
    then_i_see_the_invite_a_new_school_user_page

    when_i_fill_in_the_existing_users_details
    and_i_submit_invite_school_user_form
    and_i_click_through_to_the_school_page
    then_i_see_the_existing_user_on_the_school_page
    and_the_school_is_shown_as_contacted
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def and_there_is_an_existing_user_on_another_school
    existing_user
  end

  def when_i_visit_the_school_page
    school_page.load(urn: school.urn)
  end

  def and_i_click_the_invite_a_new_user_button
    school_page.invite_a_new_user.click
  end

  def then_i_see_the_invite_a_new_school_user_page
    expect(new_school_user_page).to be_displayed
  end

  def when_fill_in_invite_school_user_form
    new_school_user_page.name.set 'John Doe'
    new_school_user_page.email_address.set 'john@example.com'
    new_school_user_page.phone.set '020 1'
  end

  def when_i_fill_in_the_existing_users_details
    new_school_user_page.name.set 'New Name'
    new_school_user_page.email_address.set 'existinguser@example.com'
    new_school_user_page.phone.set '0202 022202'
    new_school_user_page.orders_devices_no.click
  end

  def and_i_submit_invite_school_user_form
    new_school_user_page.send_invite.click
  end

  def and_i_click_through_to_the_school_page
    click_on school.name
    expect(school_page).to be_displayed
  end

  def then_i_see_the_user_on_the_school_page
    expect(page).to have_content('John Doe')
    expect(page).to have_content('john@example.com')
    expect(page).to have_content('020 1')
  end

  def then_i_see_the_existing_user_on_the_school_page
    expect(page).to have_content(existing_user.full_name)
    expect(page).to have_content('existinguser@example.com')
    expect(page).to have_content(existing_user.telephone)
  end

  def and_the_school_is_shown_as_contacted
    expect(page).to have_content('School contacted')
  end
end
