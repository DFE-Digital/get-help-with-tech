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

  scenario 'see a school that is able to fully order' do
    given_a_school_can_order
    when_i_visit_the_your_schools_page
    then_i_dont_see_the_order_devices_link
    then_i_see_the_school_in_the_schools_reporting_closure_list
  end

  scenario 'see a school that is able to order for specific circumstances' do
    given_a_school_can_order_for_specific_circumstances
    when_i_visit_the_your_schools_page
    then_i_dont_see_the_order_devices_link
    then_i_see_the_school_in_the_schools_with_approved_requests_list
  end

  scenario 'see a schools that is fully open' do
    given_a_school_is_fully_open
    when_i_visit_the_your_schools_page
    then_i_dont_see_the_order_devices_link
    then_i_see_the_school_in_the_fully_open_schools_list
  end

  scenario 'when the trust manages centrally' do
    given_there_are_schools_in_the_pool
    when_i_visit_the_your_schools_page
    then_i_see_the_order_devices_link
    then_i_see_the_summary_pooled_device_count_card
  end

  scenario 'when the trust manages centrally but there is nothing to order' do
    given_there_are_schools_in_the_pool_that_cant_order
    when_i_visit_the_your_schools_page
    then_i_dont_see_the_order_devices_link
    then_i_see_the_summary_pooled_device_count_card
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

  def given_a_school_can_order
    schools.first.can_order!
  end

  def given_a_school_can_order_for_specific_circumstances
    schools.second.can_order_for_specific_circumstances!
  end

  def given_a_school_is_fully_open
    schools.first.can_order!
    schools.second.can_order_for_specific_circumstances!
    schools.third.cannot_order!
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
    click_link 'Get laptops and tablets'
  end

  def when_i_follow_the_your_schools_link
    click_link 'Your schools'
  end

  def then_i_see_the_get_laptops_and_tablets_page
    expect(page).to have_css('h1', text: 'Get laptops')
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

  def then_i_see_the_school_in_the_schools_reporting_closure_list
    school = schools.first
    expect(your_schools_page.ordering_school_rows[0].title).to have_content(school.name)
    expect(your_schools_page.ordering_school_rows[0].who_will_order_devices).to have_content('Trust')
    expect(your_schools_page.ordering_school_rows[0].allocation).to have_content(pluralize(school.std_device_allocation.raw_allocation, 'device'))
    expect(your_schools_page.ordering_school_rows[0].allocation).to have_content(pluralize(school.coms_device_allocation&.raw_allocation, 'router'))
  end

  def then_i_see_the_school_in_the_schools_with_approved_requests_list
    school = schools.second
    expect(your_schools_page.specific_circumstances_school_rows[0].title).to have_content(school.name)
    expect(your_schools_page.specific_circumstances_school_rows[0].who_will_order_devices).to have_content('Trust')
    expect(your_schools_page.specific_circumstances_school_rows[0].allocation).to have_content(pluralize(school.std_device_allocation.raw_allocation, 'device'))
    expect(your_schools_page.specific_circumstances_school_rows[0].allocation).to have_content(pluralize(school.coms_device_allocation&.raw_allocation, 'router'))
  end

  def then_i_see_the_school_in_the_fully_open_schools_list
    school = schools.third
    expect(your_schools_page.cannot_order_yet_school_rows[0].title).to have_content(school.name)
    expect(your_schools_page.cannot_order_yet_school_rows[0].who_will_order_devices).to have_content('School')
    expect(your_schools_page.cannot_order_yet_school_rows[0].allocation).to have_content("#{school.std_device_allocation.raw_allocation} #{'device'.pluralize(school.std_device_allocation.raw_allocation)}")
    expect(your_schools_page.cannot_order_yet_school_rows[0].allocation).to have_content("#{school.coms_device_allocation&.raw_allocation} #{'router'.pluralize(school.coms_device_allocation&.raw_allocation || 0)}")
  end

  def then_i_see_the_summary_pooled_device_count_card
    expect(page).to have_content("#{responsible_body.name} has:")
    std_count = responsible_body.std_device_pool.cap - responsible_body.std_device_pool.devices_ordered
    coms_count = responsible_body.coms_device_pool.cap - responsible_body.coms_device_pool.devices_ordered
    expected =
      if std_count == 0 && coms_count == 0
        'No devices left to order'
      else
        "#{std_count} #{'device'.pluralize(std_count)} and #{coms_count} #{'router'.pluralize(coms_count)} available to order"
      end
    expect(page).to have_content(expected)
  end
end
