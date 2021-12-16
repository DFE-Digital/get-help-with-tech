require 'rails_helper'

RSpec.feature 'Ordering devices' do
  let(:responsible_body) { create(:local_authority) }
  let(:schools) { create_list(:school, 6, :manages_orders, :with_headteacher, laptops: [1, 1, 0], responsible_body: responsible_body) }
  let(:user) { create(:local_authority_user, :with_a_confirmed_techsource_account, responsible_body: responsible_body, orders_devices: true) }
  let(:user_no_ts) { create(:local_authority_user, responsible_body: responsible_body, orders_devices: false) }
  let(:user_awaiting_ts) { create(:local_authority_user, responsible_body: responsible_body, orders_devices: true) }

  before do
    stub_computacenter_outgoing_api_calls
    given_my_order_information_is_up_to_date
  end

  scenario 'navigate to order devices page' do
    given_i_am_signed_in_as_a_responsible_body_user
    when_i_visit_the_responsible_body_home_page
    and_i_follow_the_get_laptops_and_tablets_link
    then_i_see_the_get_laptops_and_tablets_page

    when_i_follow_the_order_devices_link
    then_i_see_the_cannot_order_devices_yet_page
  end

  scenario 'a responsible body that cannot order devices yet' do
    given_i_am_signed_in_as_a_responsible_body_user
    when_i_visit_the_responsible_body_home_page
    and_i_follow_the_get_laptops_and_tablets_link
    then_i_see_the_get_laptops_and_tablets_page

    when_i_follow_the_order_devices_link
    then_i_see_that_i_will_be_able_to_order_soon
  end

  scenario 'a centrally managed school can order for specific circumstances' do
    given_i_am_signed_in_as_a_responsible_body_user
    given_a_centrally_managed_school_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_for_specific_circumstances_page
  end

  scenario 'a centrally managed school can order full allocation' do
    given_i_am_signed_in_as_a_responsible_body_user
    given_a_centrally_managed_school_can_order_full_allocation
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_1_school_that_i_need_to_place_orders_for
  end

  scenario 'centrally managed schools that can order for specific circumstances and full allocation' do
    given_i_am_signed_in_as_a_responsible_body_user
    given_a_centrally_managed_school_can_order_full_allocation
    given_a_centrally_managed_school_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_2_schools_that_i_need_to_place_orders_for
  end

  scenario 'centrally managed school can order but logged in user does not have a TS account' do
    given_i_am_signed_in_as_a_responsible_body_user_with_no_ts_account
    given_a_centrally_managed_school_can_order_full_allocation
    when_i_visit_the_order_devices_page
    then_i_see_no_ts_account_page
  end

  scenario 'centrally managed school can order but logged in user is awaiting a TS account' do
    given_i_am_signed_in_as_a_responsible_body_user_with_ts_awaiting
    given_a_centrally_managed_school_can_order_full_allocation
    when_i_visit_the_order_devices_page
    then_i_see_awaiting_ts_account_page
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_i_am_signed_in_as_a_responsible_body_user_with_no_ts_account
    sign_in_as user_no_ts
  end

  def given_i_am_signed_in_as_a_responsible_body_user_with_ts_awaiting
    sign_in_as user_awaiting_ts
  end

  def given_my_order_information_is_up_to_date
    responsible_body.update!(default_who_will_order_devices_for_schools: 'responsible_body')
    responsible_body.schools.update_all(will_need_chromebooks: 'no')
    SchoolSetWhoManagesOrdersService.new(schools[0], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[1], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[2], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[3], :responsible_body).call
    SchoolSetWhoManagesOrdersService.new(schools[4], :responsible_body).call
  end

  def given_a_centrally_managed_school_can_order_for_specific_circumstances
    UpdateSchoolDevicesService.new(school: schools[1],
                                   order_state: :can_order_for_specific_circumstances,
                                   laptop_allocation: 8,
                                   circumstances_laptops: -4).call
  end

  def given_a_centrally_managed_school_can_order_full_allocation
    UpdateSchoolDevicesService.new(school: schools[2], order_state: :can_order, laptop_allocation: 7).call
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

  def then_i_see_the_order_for_specific_circumstances_page
    expect(page).to have_css('h1', text: 'You can order devices for specific circumstances')
    expect(page).to have_text(schools[1].name)

    expect(page).to have_text('Devices ordered – 0')
    expect(page).to have_text('Devices remaining – 4')
    expect(page).to have_text('Routers are also available while in stock.')
  end

  def then_i_see_the_order_now_page
    expect(page).to have_css('h1', text: 'Order devices')
  end

  def and_i_see_1_school_that_i_need_to_place_orders_for
    expect(page).to have_text('Schools you can place orders for')
    expect(page).to have_text("#{schools[2].name} (URN: #{schools[2].urn})")
    expect(page).to have_text('Devices ordered – 0')
    expect(page).to have_text('Devices remaining – 7')
  end

  def and_i_see_2_schools_that_i_need_to_place_orders_for
    expect(page).to have_text('Schools you can place orders for')
    expect(page).to have_text("#{schools[1].name} (URN: #{schools[1].urn})")
    expect(page).to have_text('Devices ordered – 0')
    expect(page).to have_text('Devices remaining – 7')
    expect(page).to have_text("#{schools[2].name} (URN: #{schools[2].urn})")
    expect(page).to have_text('Devices ordered – 0')
    expect(page).to have_text('Devices remaining – 4')
  end

  def what_to_order_availability(school)
    "Order #{school.devices_available_to_order(:laptop)} devices"
  end

  def what_to_order_state(school)
    "You’ve ordered #{school.devices_ordered(:laptop)} devices"
  end

  def then_i_see_that_i_will_be_able_to_order_soon
    expect(page).to have_content('Ordering will be opened as soon as possible.')
  end

  def then_i_see_no_ts_account_page
    expect(page).to have_content('Your organisation can order devices')
    expect(page).to have_content('You do not have a TechSource account')
  end

  def then_i_see_awaiting_ts_account_page
    expect(page).to have_content('You’ll be able to order once your TechSource account is ready')
  end
end
