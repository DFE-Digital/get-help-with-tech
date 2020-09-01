require 'rails_helper'

RSpec.feature 'Manage school users' do
  let(:school_user) { create(:school_user, full_name: 'AAA Smith') }
  let(:user_from_same_school) { create(:school_user, full_name: 'ZZZ Jones', school: school_user.school) }
  let(:new_school_user) { build(:school_user, full_name: 'BBB Brown', school: school_user.school) }
  let(:user_from_other_school) { create(:school_user) }
  let(:school_users_page) { PageObjects::School::UsersPage.new }

  before do
    user_from_same_school
    user_from_other_school

    sign_in_as school_user
  end

  scenario 'viewing the list of school users who can order devices' do
    when_i_follow_the_link_to_manage_who_can_order_devices
    then_i_see_a_list_of_users_for_my_school
    and_i_dont_see_users_from_other_schools
  end

  scenario 'adding a new school user' do
    when_i_follow_the_link_to_manage_who_can_order_devices
    and_i_click_the_link_to_invite_a_new_user
    then_i_see_the_form_to_invite_a_new_user

    when_i_fill_in_the_form_with_user_details
    and_i_submit_form
    then_i_see_an_updated_list_of_users_for_my_school
  end

  def when_i_follow_the_link_to_manage_who_can_order_devices
    click_on 'Manage users'

    expect(school_users_page).to be_displayed
    expect(page).to have_content 'Manage users'
  end

  def then_i_see_a_list_of_users_for_my_school
    expect(school_users_page.user_rows[0]).to have_content('AAA Smith')
    expect(school_users_page.user_rows[1]).to have_content('ZZZ Jones')
  end

  def and_i_dont_see_users_from_other_schools
    expect(school_users_page).not_to have_content(user_from_other_school.full_name)
  end

  def and_i_click_the_link_to_invite_a_new_user
    click_link 'Invite a new user'
  end

  def then_i_see_the_form_to_invite_a_new_user
    expect(page).to have_field('Name')
    expect(page).to have_field('Email address')
    expect(page).to have_field('Telephone number')
  end

  def when_i_fill_in_the_form_with_user_details
    fill_in 'Name', with: new_school_user.full_name
    fill_in 'Email address', with: new_school_user.email_address
    fill_in 'Telephone', with: new_school_user.telephone
    choose 'No'
  end

  def and_i_submit_form
    click_button 'Send invite'
  end

  def then_i_see_an_updated_list_of_users_for_my_school
    expect(school_users_page.user_rows[0]).to have_content('AAA Smith')
    expect(school_users_page.user_rows[1]).to have_content('BBB Brown')
    expect(school_users_page.user_rows[2]).to have_content('ZZZ Jones')
  end
end
