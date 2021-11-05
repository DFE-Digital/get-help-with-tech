require 'rails_helper'

RSpec.feature 'Ordering devices within a virtual pool' do
  let(:responsible_body) { create(:trust, :manages_centrally) }
  let(:schools) do
    create_list(:school, 4,
                :manages_orders,
                :with_headteacher,
                laptops: [1, 0, 0],
                routers: [1, 0, 0],
                responsible_body: responsible_body)
  end
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
    and_i_do_not_see_a_section_on_ordering_chromebooks
  end

  scenario 'a centrally managed school that can order for specific circumstances' do
    given_a_centrally_managed_school_within_a_pool_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_do_not_see_a_section_on_ordering_chromebooks
  end

  scenario 'centrally managed schools that can order for specific circumstances and full allocation' do
    given_a_centrally_managed_school_within_a_pool_can_order_full_allocation
    given_a_centrally_managed_school_within_a_pool_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
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
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_my_order_information_is_up_to_date
    ResponsibleBodySetWhoWillOrderDevicesService.new(responsible_body, :responsible_body).call
    responsible_body.update!(vcap_feature_flag: true)
    responsible_body.schools.update_all(will_need_chromebooks: 'no')
    SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[1], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[3], :responsible_body).call
  end

  def given_a_centrally_managed_school_within_a_pool_can_order_full_allocation
    UpdateSchoolDevicesService.new(school: schools[0],
                                   order_state: :can_order,
                                   laptop_allocation: 20,
                                   laptop_cap: 20,
                                   laptops_ordered: 1,
                                   router_allocation: 10,
                                   router_cap: 5,
                                   routers_ordered: 2).call
  end

  def given_a_centrally_managed_school_within_a_pool_could_order_but_cannot_order_anymore
    UpdateSchoolDevicesService.new(school: schools[3],
                                   order_state: :can_order,
                                   laptop_allocation: 3,
                                   laptop_cap: 3,
                                   laptops_ordered: 3,
                                   router_allocation: 5,
                                   router_cap: 5,
                                   routers_ordered: 5).call
  end

  def given_a_centrally_managed_school_within_a_pool_can_order_for_specific_circumstances
    UpdateSchoolDevicesService.new(school: schools[1],
                                   order_state: :can_order_for_specific_circumstances,
                                   laptop_allocation: 20,
                                   laptop_cap: 3,
                                   laptops_ordered: 1,
                                   router_allocation: 0,
                                   router_cap: 0,
                                   routers_ordered: 0).call
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
    expect(page).to have_css('h1', text: 'Order devices')
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
    expect(page).to have_css('h1', text: 'You’ve ordered all the devices you were allocated')
  end

  def and_i_do_not_see_a_section_on_ordering_chromebooks
    expect(page).not_to have_css('h3', text: 'Chromebooks')
  end

  def and_i_see_a_section_regarding_ordering_chromebooks
    expect(page).to have_css('h3', text: 'Chromebooks')
    expect(page).to have_text('If you place an order for Chromebooks, TechSource will contact you about which Google Workspace for Education Fundamentals (formerly G Suite for Education) domains you want to use')
  end

  def add_school_to_virtual_cap(school:)
    AddSchoolToVirtualCapPoolService.new(school).call
    responsible_body.reload
  end
end
