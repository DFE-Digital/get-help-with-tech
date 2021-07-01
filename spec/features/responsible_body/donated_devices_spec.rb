require 'rails_helper'

RSpec.feature 'Accessing the donated devices area as an RB user', type: :feature, with_feature_flags: { donated_devices: 'active' }, skip: 'Disabled for 30 Jun 2021 service closure' do
  let(:user) { create(:trust_user) }
  let(:responsible_body) { user.responsible_body }
  let(:school) { create(:school, :with_preorder_information, responsible_body: responsible_body) }

  before do
    responsible_body.update! who_will_order_devices: 'responsible_body'
    school.preorder_information.update!(who_will_order_devices: 'responsible_body')
    sign_in_as user
  end

  scenario 'RB that centrally manages schools can navigate to donated device form from the home page' do
    given_i_have_a_centrally_managed_school
    and_i_navigate_to_the_devices_page
    then_i_see_that_i_can_opt_in_my_schools

    and_i_click_the_donated_devices_link
    then_i_am_asked_if_i_am_interested_in_devices
    and_i_indicate_that_i_am_interested

    then_i_see_information_about_the_devices
    and_then_i_continue_to_the_next_page

    then_i_see_information_about_the_queue
    and_then_i_continue_to_the_next_page

    then_i_am_asked_if_i_am_still_interested
    and_i_indicate_that_i_am_still_interested

    # Now at: Which schools do you want to opt in?
  end

  scenario 'RB navigating to donated device form but declining interest' do
    given_i_have_a_centrally_managed_school
    and_i_navigate_to_the_devices_page
    then_i_see_that_i_can_opt_in_my_schools

    and_i_click_the_donated_devices_link
    then_i_am_asked_if_i_am_interested_in_devices
    and_i_indicate_that_i_am_not_interested

    then_i_see_that_i_have_not_been_opted_in
  end

  scenario 'RB that has devolved schools cannot see the donated device form from the home page' do
    given_i_have_a_devolved_school
    and_i_navigate_to_the_devices_page
    then_i_see_that_i_cannot_opt_in_my_schools
  end

  scenario 'RB that centrally managed but cannot see the donated device form from the home page without feature flag', with_feature_flags: { donated_devices: 'inactive' } do
    given_i_have_a_centrally_managed_school
    and_i_navigate_to_the_devices_page
    then_i_see_that_i_cannot_opt_in_my_schools
  end

private

  def given_i_have_a_devolved_school
    school.preorder_information.update!(who_will_order_devices: 'school')
  end

  def given_i_have_a_centrally_managed_school
    school.preorder_information.update!(who_will_order_devices: 'responsible_body')
  end

  def and_i_navigate_to_the_devices_page
    visit responsible_body_home_path
    visit responsible_body_devices_path
  end

  def and_i_click_the_donated_devices_link
    click_on 'Opt in to the Daily Mail’s donated devices scheme'
  end

  def and_i_indicate_that_i_am_interested
    choose 'Yes, tell me more'
    click_on 'Continue'
  end

  def and_i_indicate_that_i_am_not_interested
    choose 'No, not at the moment'
    click_on 'Continue'
  end

  def and_i_indicate_that_i_am_still_interested
    choose 'Yes'
    click_on 'Continue'
  end

  def and_then_i_continue_to_the_next_page
    click_on 'Continue'
  end

  def then_i_see_that_i_can_opt_in_my_schools
    expect(page).to have_content('Opt in to the Daily Mail’s donated devices scheme')
  end

  def then_i_see_that_i_cannot_opt_in_my_schools
    expect(page).not_to have_content('Opt in to the Daily Mail’s donated devices scheme')
  end

  def then_i_am_asked_if_i_am_interested_in_devices
    expect(page).to have_content('Do your schools and colleges want donated devices')
  end

  def then_i_see_information_about_the_devices
    expect(page).to have_content('About donated devices')
  end

  def then_i_see_information_about_the_queue
    expect(page).to have_content('There’s a queue for these devices')
  end

  def then_i_see_that_i_have_not_been_opted_in
    expect(page).to have_content('No schools or colleges have been opted in')
  end

  def then_i_am_asked_if_i_am_still_interested
    expect(page).to have_content('Are you still interested?')
  end
end
