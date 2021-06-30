require 'rails_helper'

RSpec.feature 'Viewing your schools' do
  include ActionView::Helpers::TextHelper

  let(:responsible_body) { create(:trust, :manages_centrally) }
  let(:schools) { create_list(:school, 3, :with_preorder_information, :with_headteacher_contact, :with_std_device_allocation, :with_coms_device_allocation, responsible_body: responsible_body) }
  let!(:user) { create(:local_authority_user, responsible_body: responsible_body) }

  let(:your_schools_page) { PageObjects::ResponsibleBody::SchoolsPage.new }

  before do
    stub_computacenter_outgoing_api_calls
    given_i_am_signed_in_as_a_responsible_body_user
    given_my_order_information_is_up_to_date
  end

  scenario 'navigate to your schools page' do
    when_i_visit_the_responsible_body_home_page
    and_i_follow_the_get_laptops_and_tablets_link
    then_i_see_the_get_laptops_and_tablets_page

    when_i_follow_the_your_schools_link
    then_i_see_the_your_schools_page
    then_i_dont_see_the_order_devices_link
  end

  scenario 'when the trust manages centrally but there is nothing to order' do
    given_there_are_schools_in_the_pool_that_cant_order
    when_i_visit_the_your_schools_page
    then_i_dont_see_the_order_devices_link
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_my_order_information_is_up_to_date
    responsible_body.update!(who_will_order_devices: 'responsible_body', vcap_feature_flag: true)
    PreorderInformation.where(school_id: responsible_body.schools).update_all(will_need_chromebooks: 'no')
    schools[0].preorder_information.responsible_body_will_order_devices!
    schools[1].preorder_information.responsible_body_will_order_devices!
    schools[2].preorder_information.school_will_order_devices!
  end

  def given_there_are_schools_in_the_pool
    schools.first.can_order!
    schools.first.std_device_allocation.update!(cap: 5, allocation: 5, devices_ordered: 2)
    responsible_body.add_school_to_virtual_cap_pools!(schools.first)
    schools.second.can_order_for_specific_circumstances!
    schools.second.std_device_allocation.update!(cap: 5, allocation: 20, devices_ordered: 0)
    responsible_body.add_school_to_virtual_cap_pools!(schools.second)
  end

  def given_there_are_schools_in_the_pool_that_cant_order
    schools.first.can_order!
    schools.first.std_device_allocation.update!(cap: 5, allocation: 5, devices_ordered: 5)
    responsible_body.add_school_to_virtual_cap_pools!(schools.first)
    schools.second.can_order_for_specific_circumstances!
    schools.second.std_device_allocation.update!(cap: 5, allocation: 20, devices_ordered: 5)
    responsible_body.add_school_to_virtual_cap_pools!(schools.second)
  end

  def when_i_visit_the_responsible_body_home_page
    visit responsible_body_home_path
    expect(page).to have_http_status(:ok)
  end

  def when_i_visit_the_your_schools_page
    visit responsible_body_devices_schools_path
    expect(page).to have_http_status(:ok)
  end

  def and_i_follow_the_get_laptops_and_tablets_link
    visit responsible_body_devices_path
  end

  def when_i_follow_the_your_schools_link
    click_link 'Your schools'
  end

  def and_i_select_a_centrally_managed_school
    click_link "#{schools[0].name} (#{schools[0].urn})"
  end

  def and_i_select_a_devolved_school
    click_link "#{schools[2].name} (#{schools[2].urn})"
  end

  def when_i_click_the_change_who_will_order_link
    find_all(:css, '.school-details-summary-list .govuk-summary-list__row')[1].click_link 'Change'
  end

  def then_i_see_text_about_managing_centrally_being_irreversible
    expect(page).to have_text('You will not be able to transfer back ordering responsibility to the school once you’ve decided to do it this way')
  end

  def then_i_dont_see_change_links_for_who_will_order
    result = find_all(:css, '.school-details-summary-list .govuk-summary-list__row')[1]
    expect(result).to have_text('The trust orders devices')
    expect(result).not_to have_link('Change')
  end

  def then_i_see_the_get_laptops_and_tablets_page
    expect(page).to have_css('h1', text: 'Get devices')
    expect(page).to have_link('Your schools')
    expect(page).to have_link('Order devices')
  end

  def then_i_see_the_your_schools_page
    expect(page).to have_css('h1', text: 'Your schools')
  end

  def then_i_see_the_order_devices_link
    expect(page).to have_link('Order devices')
  end

  def then_i_dont_see_the_order_devices_link
    expect(page).not_to have_link('Order devices')
  end
end
