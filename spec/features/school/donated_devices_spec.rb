require 'rails_helper'

RSpec.feature 'Accessing the donated devices area as a school user', type: :feature, with_feature_flags: { donated_devices: 'active' } do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  before do
    school.create_preorder_information!(who_will_order_devices: 'school')
    sign_in_as user
  end

  scenario 'devolved school can navigate to donated device form from the home page' do
    given_devolved_school
    and_i_navigate_to_the_home_page
    then_see_that_i_can_opt_in
  end

  scenario 'centrally managed school cannot see the donated device form from the home page' do
    given_centrally_managed_school
    and_i_navigate_to_the_home_page
    then_see_that_i_cannot_opt_in
  end

private

  def given_devolved_school
    school.preorder_information.update!(who_will_order_devices: 'school')
  end

  def given_centrally_managed_school
    school.preorder_information.update!(who_will_order_devices: 'responsible_body')
  end

  def and_i_navigate_to_the_home_page
    visit home_school_path(school)
  end

  def then_see_that_i_can_opt_in
    expect(page).to have_content('Opt in to the Daily Mail’s donated devices scheme')
  end

  def then_see_that_i_cannot_opt_in
    expect(page).not_to have_content('Opt in to the Daily Mail’s donated devices scheme')
  end
end
