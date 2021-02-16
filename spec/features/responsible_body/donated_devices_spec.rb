require 'rails_helper'

RSpec.feature 'Accessing the donated devices area as an RB user', type: :feature, with_feature_flags: { donated_devices: 'active' } do
  let(:user) { create(:trust_user) }
  let(:responsible_body) { user.responsible_body }
  let(:school) { create(:school, :with_preorder_information, responsible_body: responsible_body) }

  before do
    responsible_body.update! who_will_order_devices: 'responsible_body'
    school.preorder_information.update!(who_will_order_devices: 'responsible_body')
    sign_in_as user
  end

  scenario 'RB that centrally manages schools can navigate to donated device form from the home page' do
    given_centrally_managed_school
    and_i_navigate_to_the_devices_page
    then_see_that_i_can_opt_in_my_schools
  end

  scenario 'RB that has devolved schools cannot see the donated device form from the home page' do
    given_devolved_school
    and_i_navigate_to_the_devices_page
    then_see_that_i_cannot_opt_in_my_schools
  end

private

  def given_devolved_school
    school.preorder_information.update!(who_will_order_devices: 'school')
  end

  def given_centrally_managed_school
    school.preorder_information.update!(who_will_order_devices: 'responsible_body')
  end

  def and_i_navigate_to_the_devices_page
    visit responsible_body_home_path
    click_on 'Get laptops and tablets'
  end

  def then_see_that_i_can_opt_in_my_schools
    expect(page).to have_content('Opt in to the Daily Mail’s donated devices scheme')
  end

  def then_see_that_i_cannot_opt_in_my_schools
    expect(page).not_to have_content('Opt in to the Daily Mail’s donated devices scheme')
  end
end
