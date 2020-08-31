require 'rails_helper'

RSpec.feature 'Manage school users' do
  let(:school_user) { create(:school_user, full_name: 'AAA Smith') }
  let(:user_from_same_school) { create(:school_user, full_name: 'ZZZ Jones', school: school_user.school) }
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

  def when_i_follow_the_link_to_manage_who_can_order_devices
    click_on 'Manage who can order devices'

    expect(school_users_page).to be_displayed
    expect(page).to have_content 'Manage who can order devices'
  end

  def then_i_see_a_list_of_users_for_my_school
    expect(school_users_page.user_rows[0]).to have_content('AAA Smith')
    expect(school_users_page.user_rows[1]).to have_content('ZZZ Jones')
  end

  def and_i_dont_see_users_from_other_schools
    expect(school_users_page).not_to have_content(user_from_other_school.full_name)
  end
end
