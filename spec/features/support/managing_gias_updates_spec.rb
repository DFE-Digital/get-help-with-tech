require 'rails_helper'

RSpec.feature 'Managing GIAS updates to schools from the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry') }
  let(:responsible_bodies_page) { PageObjects::Support::ResponsibleBodiesPage.new }
  let(:responsible_body_page) { PageObjects::Support::ResponsibleBodyPage.new }
  let(:school) { School.find_by_name('Alpha School') }
  let(:school_contact) { school.contacts.first }

  scenario 'Third-line support users can see the GIAS updates' do
    when_i_sign_in_as_a_third_line_support_user
    and_i_visit_the_support_page
    then_i_see_a_link_to_the_gias_updates
  end

  scenario 'Non-third-line support users cannot see the GIAS updates' do
    when_i_sign_in_as_a_support_user
    and_i_visit_the_support_page
    then_i_do_not_see_a_link_to_the_gias_updates
  end

  def when_i_sign_in_as_a_third_line_support_user
    sign_in_as create(:support_user, :third_line)
  end

  def when_i_sign_in_as_a_support_user
    sign_in_as create(:support_user)
  end

  def and_i_visit_the_support_page
    visit support_home_path
  end

  def then_i_see_a_link_to_the_gias_updates
    expect(page).to have_link('GIAS updates')
  end

  def then_i_do_not_see_a_link_to_the_gias_updates
    expect(page).not_to have_link('GIAS updates')
  end
end
