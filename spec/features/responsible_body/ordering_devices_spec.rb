require 'rails_helper'

RSpec.feature 'Ordering devices' do
  let(:responsible_body) { create(:local_authority) }
  let(:schools) { create_list(:school, 6, :with_preorder_information, :with_headteacher_contact, :with_std_device_allocation, responsible_body: responsible_body) }
  let!(:user) { create(:local_authority_user, responsible_body: responsible_body) }

  before do
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

  scenario 'a responsible body that cannot order devices yet' do
    when_i_visit_the_responsible_body_home_page
    and_i_follow_the_get_laptops_and_tablets_link
    then_i_see_the_get_laptops_and_tablets_page

    when_i_follow_the_order_devices_link
    then_i_see_that_i_will_be_able_to_order_soon
  end

  scenario 'a centrally managed school can order for specific circumstances' do
    given_a_centrally_managed_school_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_for_specific_circumstances_page
  end

  scenario 'a centrally managed school can order full allocation' do
    given_a_centrally_managed_school_can_order_full_allocation
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_1_school_that_i_need_to_place_orders_for
  end

  scenario 'centrally managed schools that can order for specific circumstances and full allocation' do
    given_a_centrally_managed_school_can_order_full_allocation
    given_a_centrally_managed_school_can_order_for_specific_circumstances
    when_i_visit_the_order_devices_page
    then_i_see_the_order_now_page
    and_i_see_2_schools_that_i_need_to_place_orders_for
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def given_my_order_information_is_up_to_date
    responsible_body.update!(who_will_order_devices: 'responsible_body')
    PreorderInformation.where(school_id: responsible_body.schools).update_all(will_need_chromebooks: 'no')
    schools[0].preorder_information.responsible_body_will_order_devices!
    schools[1].preorder_information.responsible_body_will_order_devices!
    schools[2].preorder_information.responsible_body_will_order_devices!
    schools[3].preorder_information.school_will_order_devices!
    schools[4].preorder_information.school_will_order_devices!
  end

  def given_a_centrally_managed_school_can_order_for_specific_circumstances
    schools[1].can_order_for_specific_circumstances!
    schools[1].std_device_allocation.update!(cap: 4, allocation: 8)
  end

  def given_a_centrally_managed_school_can_order_full_allocation
    schools[2].can_order!
    schools[2].std_device_allocation.update!(cap: 7, allocation: 7)
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
    click_link 'Get laptops'
  end

  def then_i_see_the_get_laptops_and_tablets_page
    expect(page).to have_css('h1', text: 'Get laptops')
    expect(page).to have_link('Your schools')
    expect(page).to have_link('Order devices')
  end

  def then_i_see_the_cannot_order_devices_yet_page
    expect(page).to have_css('h1', text: 'You cannot order devices yet')
  end

  def then_i_see_the_order_for_specific_circumstances_page
    expect(page).to have_css('h1', text: 'You can order devices for specific circumstances')
    expect(page).to have_text(schools[1].name)
    expect(page).to have_text('Order 4 devices for specific circumstances')
  end

  def then_i_see_the_order_now_page
    expect(page).to have_css('h1', text: 'Order devices')
  end

  def and_i_see_1_school_that_i_need_to_place_orders_for
    expect(page).to have_text('Schools you need to place orders for')
    expect(page).to have_text("#{schools[2].name} (URN: #{schools[2].urn})")
    expect(page).to have_text(what_to_order_availability(schools[2]))
    expect(page).to have_text(what_to_order_state(schools[2]))
  end

  def and_i_see_2_schools_that_i_need_to_place_orders_for
    expect(page).to have_text('Schools you need to place orders for')
    expect(page).to have_text("#{schools[1].name} (URN: #{schools[1].urn})")
    expect(page).to have_text(what_to_order_availability(schools[1]))
    expect(page).to have_text(what_to_order_state(schools[1]))
    expect(page).to have_text("#{schools[2].name} (URN: #{schools[2].urn})")
    expect(page).to have_text(what_to_order_availability(schools[2]))
    expect(page).to have_text(what_to_order_state(schools[2]))
  end

  def what_to_order_availability(school)
    "Order #{school.std_device_allocation.devices_available_to_order} devices"
  end

  def what_to_order_state(school)
    "You’ve ordered #{school.std_device_allocation.devices_ordered} devices"
  end

  def then_i_see_that_i_will_be_able_to_order_soon
    expect(page).to have_content('Ordering will be opened as soon as possible.')
  end
end
