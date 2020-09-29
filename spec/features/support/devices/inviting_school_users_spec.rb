require 'rails_helper'

RSpec.feature 'Inviting school users' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school) }
  let(:school_page) { PageObjects::Support::Devices::SchoolDetailsPage.new }
  let(:new_school_user_page) { PageObjects::Support::Devices::Schools::NewUserPage.new }

  scenario 'support invites new school user' do
    given_i_am_signed_in_as_a_support_user
    when_i_visit_the_school_page
    and_i_click_the_invite_a_new_user_button
    then_i_see_the_invite_a_new_school_user_page

    when_fill_in_invite_school_user_form
    and_i_submit_invite_school_user_form
    then_i_see_the_school_page
    and_i_see_the_user_on_the_school_page
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
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
    new_school_user_page.email.set 'john@example.com'
    new_school_user_page.phone.set '020 1'
    new_school_user_page.orders_devices_no.click
  end

  def and_i_submit_invite_school_user_form
    new_school_user_page.submit.click
  end

  def then_i_see_the_school_page
    expect(school_page).to be_displayed
  end

  def and_i_see_the_user_on_the_school_page
    expect(page).to have_content('John Doe')
    expect(page).to have_content('john@example.com')
    expect(page).to have_content('020 1')
  end
end
