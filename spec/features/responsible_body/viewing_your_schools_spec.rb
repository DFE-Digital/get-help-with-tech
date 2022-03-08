require 'rails_helper'

RSpec.feature 'Viewing your schools' do
  include ActionView::Helpers::TextHelper

  let(:responsible_body) { create(:trust, :manages_centrally) }
  let(:schools) { create_list(:school, 3, :manages_orders, :with_headteacher, laptops: [1, 1, 0], routers: [1, 1, 0], responsible_body: responsible_body) }
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
    then_i_see_the_summary_pooled_device_count_card
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_my_order_information_is_up_to_date
    ResponsibleBodySetWhoWillOrderDevicesService.new(responsible_body, :responsible_body).call
    responsible_body.update!(vcap: true)
    responsible_body.schools.update_all(will_need_chromebooks: 'no')
    SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[1], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[2], :responsible_body).call
  end

  def given_there_are_schools_in_the_pool
    UpdateSchoolDevicesService.new(school: schools.first,
                                   order_state: :can_order,
                                   laptop_allocation: 5,
                                   laptops_ordered: 2).call
    UpdateSchoolDevicesService.new(school: schools.second,
                                   order_state: :can_order_for_specific_circumstances,
                                   laptop_allocation: 20,
                                   circumstances_laptops: -15,
                                   laptops_ordered: 0).call
  end

  def given_there_are_schools_in_the_pool_that_cant_order
    UpdateSchoolDevicesService.new(school: schools.first,
                                   order_state: :can_order,
                                   laptop_allocation: 5,
                                   laptops_ordered: 5,
                                   router_allocation: 1,
                                   routers_ordered: 1).call
    UpdateSchoolDevicesService.new(school: schools.second,
                                   order_state: :can_order_for_specific_circumstances,
                                   laptop_allocation: 20,
                                   circumstances_laptops: -15,
                                   laptops_ordered: 5,
                                   router_allocation: 0,
                                   routers_ordered: 0).call
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
    expect(page).to have_css('h1', text: 'Order devices')
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

  def then_i_see_the_summary_pooled_device_count_card
    expect(page).to have_css('#allocation')
  end
end
