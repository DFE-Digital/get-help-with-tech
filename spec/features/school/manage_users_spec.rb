require 'rails_helper'

RSpec.feature 'Manage school users' do
  let(:school_user) { create(:school_user, full_name: 'AAA Smith') }
  let(:user_from_same_school) { create(:school_user, full_name: 'ZZZ Jones', school: school_user.school) }
  let(:user_from_same_school_deleted) { create(:school_user, :deleted, full_name: 'John Doe', school: school_user.school) }
  let(:new_school_user) { build(:school_user, full_name: 'BBB Brown', school: school_user.school) }
  let(:user_from_other_school) { create(:school_user) }
  let(:school_users_page) { PageObjects::School::UsersPage.new }
  let(:responsible_body_user) { create(:trust_user, full_name: 'JJJ Johnson') }

  before do
    # disable computacenter user import API calls
    allow(Settings.computacenter.service_now_user_import_api).to receive(:endpoint).and_return(nil)
    stub_computacenter_outgoing_api_calls
    user_from_same_school
    user_from_other_school
    user_from_same_school_deleted

    sign_in_as school_user
  end

  scenario 'viewing the list of school users who can order devices' do
    when_i_navigate_to_manage_users
    then_i_see_a_list_of_users_for_my_school
    and_i_dont_see_users_from_other_schools
  end

  scenario 'editing a school user' do
    when_i_navigate_to_manage_users
    and_i_click_the_link_to_change_a_user_from_the_same_school
    then_i_see_a_form_populated_with_the_users_details

    when_i_change_the_details
    and_i_save_my_changes
    then_i_see_the_updated_details_for_the_user
  end

  def when_i_navigate_to_manage_users
    visit school_users_path(school_user.school)

    expect(school_users_page).to be_displayed
  end

  def then_i_see_a_list_of_users_for_my_school
    expect(school_users_page.user_rows[0]).to have_content('AAA Smith')
    expect(school_users_page.user_rows[1]).to have_content('ZZZ Jones')

    expect(page).not_to have_content(user_from_same_school_deleted.full_name)
  end

  def and_i_dont_see_users_from_other_schools
    expect(school_users_page).not_to have_content(user_from_other_school.full_name)
  end

  def and_i_click_the_link_to_change_a_user_from_the_same_school
    click_link 'Change ZZZ Jones', match: :first
  end

  def then_i_see_a_form_populated_with_the_users_details
    expect(page).to have_selector('h1', text: 'Change user details')
    expect(page).to have_field('Name', with: user_from_same_school.full_name)
    expect(page).to have_field('Email address', with: user_from_same_school.email_address)
    expect(page).to have_field('Telephone number', with: user_from_same_school.telephone)
  end

  def when_i_change_the_details
    fill_in 'Telephone', with: '01234567890'
  end

  def and_i_save_my_changes
    click_button 'Save'
  end

  def then_i_see_the_updated_details_for_the_user
    expect(school_users_page.user_rows[1]).to have_selector('h3', text: 'ZZZ Jones')
    expect(school_users_page.user_rows[1]).to have_selector('dd', text: '01234567890')
  end
end
