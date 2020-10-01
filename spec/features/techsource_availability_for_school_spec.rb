require 'rails_helper'

RSpec.feature 'TechSource availability for school' do
  include ViewHelper

  let(:school) { create(:school, :with_std_device_allocation) }
  let(:school_user) do
    create(:school_user,
           school: school,
           orders_devices: true,
           techsource_account_confirmed_at: 1.second.ago,
           full_name: 'AAA Smith')
  end

  after do
    Timecop.return
  end

  scenario 'before the techsource maintenance window' do
    given_it_is_before_the_techsource_maintenance_window
    given_i_am_signed_in_as_a_school_user
    given_i_can_order_devices
    when_i_visit_the_order_devices_page
    then_i_see_a_warning_notice
  end

  scenario 'during the techsource maintenance window' do
    given_it_is_during_the_techsource_maintenance_window
    given_i_am_signed_in_as_a_school_user
    given_i_can_order_devices
    when_i_visit_the_order_devices_page
    then_i_see_a_warning_notice
    when_i_click_the_start_now_button
    then_i_see_a_service_unavailable_page
  end

  scenario 'after the techsource maintenance window' do
    given_it_is_after_the_techsource_maintenance_window
    given_i_am_signed_in_as_a_school_user
    given_i_can_order_devices
    when_i_visit_the_order_devices_page
    then_i_do_not_see_a_warning_notice
  end

  def given_i_am_signed_in_as_a_school_user
    sign_in_as school_user
  end

  def given_i_can_order_devices
    school.std_device_allocation.update!(cap: 50, allocation: 100, devices_ordered: 20)
    school.can_order!
  end

  def when_i_visit_the_order_devices_page
    visit school_order_devices_path
    expect(page).to have_http_status(:ok)
  end

  def given_it_is_before_the_techsource_maintenance_window
    Timecop.travel(Time.zone.local(2020, 9, 25, 23, 0, 0))
  end

  def given_it_is_during_the_techsource_maintenance_window
    Timecop.travel(Time.zone.local(2020, 9, 26, 8, 0, 0))
  end

  def given_it_is_after_the_techsource_maintenance_window
    Timecop.travel(Time.zone.local(2020, 9, 27, 3, 1, 0))
  end

  def then_i_see_a_warning_notice
    expect(page).to have_text('The TechSource website will be closed for maintenance on Saturday 26 September. You can order devices when it reopens on Sunday 27 September.')
  end

  def then_i_do_not_see_a_warning_notice
    expect(page).not_to have_text('The TechSource website will be closed for maintenance on Saturday 26 September. You can order devices when it reopens on Sunday 27 September.')
  end

  def when_i_click_the_start_now_button
    click_on 'Start now'
  end

  def then_i_see_a_service_unavailable_page
    expect(page).to have_current_path(techsource_start_path)
    expect(page).to have_selector('h1', text: 'Sorry, TechSource is unavailable')
  end
end
