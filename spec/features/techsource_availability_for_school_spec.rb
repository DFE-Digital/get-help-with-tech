require 'rails_helper'

RSpec.feature 'TechSource availability for school' do
  let(:school) { create(:school, laptops: [1, 1, 0]) }
  let(:school_user) do
    create(:school_user,
           school: school,
           orders_devices: true,
           techsource_account_confirmed_at: 1.second.ago,
           full_name: 'AAA Smith')
  end

  before do
    stub_computacenter_outgoing_api_calls
  end

  scenario 'well before the techsource maintenance window' do
    given_it_is_well_before_the_techsource_maintenance_window
    given_i_am_signed_in_as_a_school_user
    given_i_can_order_devices
    when_i_visit_the_order_devices_page
    then_i_do_not_see_a_warning_notice
  end

  scenario 'less than 2 days before the techsource maintenance window' do
    given_it_is_less_than_2_days_before_the_techsource_maintenance_window
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
    UpdateSchoolDevicesService.new(school: school,
                                   order_state: :can_order,
                                   over_order_reclaimed_laptops: -50,
                                   laptop_allocation: 100,
                                   laptops_ordered: 20).call
  end

  def when_i_visit_the_order_devices_page
    visit order_devices_school_path(school)
    expect(page).to have_http_status(:ok)
  end

  def given_it_is_well_before_the_techsource_maintenance_window
    Timecop.travel(Time.zone.parse('20 Nov 2020 23:00'))
    create(:supplier_outage, start_at: Time.zone.parse('3 Dec 2020 09:00'), end_at: Time.zone.parse('3 Dec 2020 22:00'))
  end

  def given_it_is_less_than_2_days_before_the_techsource_maintenance_window
    Timecop.travel(Time.zone.parse('2 Dec 2020 23:00'))
    create(:supplier_outage, start_at: Time.zone.parse('3 Dec 2020 09:00'), end_at: Time.zone.parse('3 Dec 2020 22:00'))
  end

  def given_it_is_during_the_techsource_maintenance_window
    Timecop.travel(Time.zone.parse('3 Dec 2020 09:01'))
    create(:supplier_outage, start_at: Time.zone.parse('3 Dec 2020 09:00'), end_at: Time.zone.parse('3 Dec 2020 22:00'))
  end

  def given_it_is_after_the_techsource_maintenance_window
    # needed due to end_at validation that it can't be in the past
    Timecop.travel(Time.zone.parse('2 Dec 2020 23:00'))
    create(:supplier_outage, start_at: Time.zone.parse('3 Dec 2020 09:00'), end_at: Time.zone.parse('3 Dec 2020 22:00'))

    Timecop.travel(Time.zone.parse('4 Dec 2020 23:00'))
  end

  def then_i_see_a_warning_notice
    expect(page).to have_selector('[data-module="app-tech-source-maintenance-banner"]')
  end

  def then_i_do_not_see_a_warning_notice
    expect(page).to have_no_selector('[data-module="app-tech-source-maintenance-banner"]')
  end

  def when_i_click_the_start_now_button
    click_on 'Start now'
  end

  def then_i_see_a_service_unavailable_page
    expect(page).to have_current_path(techsource_start_path)
    expect(page).to have_selector('h1', text: 'Sorry, TechSource is unavailable')
  end
end
