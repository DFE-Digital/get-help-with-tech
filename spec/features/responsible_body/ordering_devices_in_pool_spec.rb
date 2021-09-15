require 'rails_helper'

RSpec.feature 'Ordering devices within a virtual pool', skip: 'Disabled for 30 Jun 2021 service closure' do
  let(:responsible_body) { create(:trust, :manages_centrally) }
  let(:schools) { create_list(:school, 4, :manages_orders, :with_headteacher, :with_std_device_allocation, :with_coms_device_allocation, responsible_body: responsible_body) }
  let!(:user) { create(:local_authority_user, responsible_body: responsible_body) }

  before do
    stub_computacenter_outgoing_api_calls
    given_i_am_signed_in_as_a_responsible_body_user
    given_my_order_information_is_up_to_date
  end

  scenario 'navigate to order devices page' do
    when_i_visit_the_responsible_body_home_page
    and_i_follow_the_get_laptops_and_tablets_link
    then_i_see_the_get_laptops_and_tablets_page

    when_i_follow_the_order_devices_link
    then_i_see_the_cannot_order_devices_yet_page
  end

  scenario 'a centrally managed school that can order full allocation' do
    given_a_centrally_managed_school_within_a_pool_can_order_full_allocation
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_1_school_in_local_restrictions_that_i_need_to_place_orders_for
    and_i_see_1_school_in_local_restrictions_that_i_have_already_placed_orders_for
    and_i_do_not_see_a_section_on_ordering_chromebooks
  end

  scenario 'a centrally managed school that can order for specific circumstances' do
    given_a_centrally_managed_school_within_a_pool_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_1_school_with_specific_circumstances_that_i_need_to_place_orders_for
    and_i_see_1_school_with_specific_circumstances_that_i_have_already_placed_orders_for
    and_i_do_not_see_a_section_on_ordering_chromebooks
  end

  scenario 'centrally managed schools that can order for specific circumstances and full allocation' do
    given_a_centrally_managed_school_within_a_pool_can_order_full_allocation
    given_a_centrally_managed_school_within_a_pool_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_2_schools_that_i_need_to_place_orders_for
    and_i_see_2_schools_that_i_have_already_placed_orders_for
    and_i_do_not_see_a_section_on_ordering_chromebooks
  end

  scenario 'centrally managed schools with multiple Chromebook domains that can order' do
    given_there_are_multiple_chromebook_domains_being_managed
    given_a_centrally_managed_school_within_a_pool_can_order_full_allocation
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_a_section_regarding_ordering_chromebooks
  end

  scenario 'with no devices left to order' do
    given_a_centrally_managed_school_within_a_pool_could_order_but_cannot_order_anymore
    when_i_visit_the_order_devices_page
    then_i_see_the_cannot_order_anymore_page
    and_i_see_i_have_no_more_devices_to_order
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_my_order_information_is_up_to_date
    responsible_body.update!(who_will_order_devices: 'responsible_body', vcap_feature_flag: true)
    PreorderInformation.where(school_id: responsible_body.schools).update_all(will_need_chromebooks: 'no')
    schools[0].orders_managed_centrally!
    schools[1].orders_managed_centrally!
    schools[3].orders_managed_centrally!
  end

  def given_a_centrally_managed_school_within_a_pool_can_order_full_allocation
    schools[0].can_order!
    schools[0].std_device_allocation.update!(cap: 3, allocation: 20, devices_ordered: 1) # 2 left
    schools[0].coms_device_allocation.update!(cap: 5, allocation: 10, devices_ordered: 2) # 3 left
  end

  def given_a_centrally_managed_school_within_a_pool_could_order_but_cannot_order_anymore
    schools[3].can_order!
    schools[3].std_device_allocation.update!(cap: 3, allocation: 20, devices_ordered: 3) # 2 left
    schools[3].coms_device_allocation.update!(cap: 5, allocation: 10, devices_ordered: 5) # 3 left
  end

  def given_a_centrally_managed_school_within_a_pool_can_order_for_specific_circumstances
    schools[1].can_order_for_specific_circumstances!
    schools[1].std_device_allocation.update!(cap: 3, allocation: 20, devices_ordered: 1) # 2 left
    schools[1].coms_device_allocation.update!(cap: 0, allocation: 0, devices_ordered: 0) # 0 left
  end

  def given_there_are_multiple_chromebook_domains_being_managed
    schools[0].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                         school_or_rb_domain: 'school_1.com',
                                                         recovery_email_address: 'school_1@gmail.com')
    schools[1].update_chromebook_information_and_status!(will_need_chromebooks: 'yes',
                                                         school_or_rb_domain: 'school_2.com',
                                                         recovery_email_address: 'school_2@gmail.com')
  end

  def when_i_visit_the_responsible_body_home_page
    visit responsible_body_home_path
    expect(page).to have_http_status(:ok)
  end

  def when_i_visit_the_order_devices_page
    visit responsible_body_devices_order_devices_path
    expect(page).to have_http_status(:ok)
  end

  def when_i_follow_the_order_devices_link
    click_link('Order devices')
  end

  def and_i_follow_the_get_laptops_and_tablets_link
    visit responsible_body_devices_path
  end

  def then_i_see_the_get_laptops_and_tablets_page
    expect(page).to have_css('h1', text: 'Get devices')
    expect(page).to have_link('Your schools')
    expect(page).to have_link('Order devices')
  end

  def then_i_see_the_cannot_order_devices_yet_page
    expect(page).to have_css('h1', text: 'You cannot order devices yet')
  end

  def then_i_see_the_order_now_page
    expect(page).to have_css('h1', text: 'Order devices')
  end

  def then_i_see_the_cannot_order_anymore_page
    expect(page).to have_css('h1', text: 'You’ve ordered all the devices you can')
  end

  def and_i_see_1_school_in_local_restrictions_that_i_need_to_place_orders_for
    expect(page).to have_text('2 devices and 3 routers available to order')
  end

  def and_i_see_1_school_in_local_restrictions_that_i_have_already_placed_orders_for
    expect(page).to have_text('You ordered 1 device and 2 routers')
  end

  def and_i_see_1_school_with_specific_circumstances_that_i_need_to_place_orders_for
    expect(page).to have_text('2 devices and 0 routers available to order')
  end

  def and_i_see_1_school_with_specific_circumstances_that_i_have_already_placed_orders_for
    expect(page).to have_text('You ordered 1 device and 0 routers')
  end

  def and_i_see_2_schools_that_i_need_to_place_orders_for
    expect(page).to have_text('4 devices and 3 routers available to order')
  end

  def and_i_see_2_schools_that_i_have_already_placed_orders_for
    expect(page).to have_text('You ordered 2 devices and 2 routers')
  end

  def and_i_see_i_have_no_more_devices_to_order
    expect(page).to have_text('No devices left to order')
    expect(page).to have_text('You ordered 3 devices and 5 routers')
  end

  def and_i_do_not_see_a_section_on_ordering_chromebooks
    expect(page).not_to have_css('h3', text: 'Chromebooks')
  end

  def and_i_see_a_section_regarding_ordering_chromebooks
    expect(page).to have_css('h3', text: 'Chromebooks')
    expect(page).to have_text('If you place an order for Chromebooks, TechSource will contact you about which Google Workspace for Education Fundamentals (formerly G Suite for Education) domains you want to use')
  end

  def add_school_to_virtual_cap(school:)
    responsible_body.add_school_to_virtual_cap_pools!(school)
    responsible_body.calculate_virtual_caps!
  end
end
