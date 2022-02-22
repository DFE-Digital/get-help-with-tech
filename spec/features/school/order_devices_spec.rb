require 'rails_helper'

RSpec.feature 'Order devices' do
  include ViewHelper

  let(:school) { create(:school, laptops: [1, 1, 0]) }

  scenario 'when my school can order devices and I can order devices' do
    given_the_school_can_order_devices
    given_i_can_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_the_allocation_of_devices
    and_i_see_a_link_to_techsource
  end

  scenario 'when my school can order devices and I am awaiting my TechSource account' do
    given_the_school_can_order_devices
    given_i_am_awaiting_my_techsource_account
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_techsource_ready_soon
  end

  scenario 'when my school can order devices but I cannot order devices' do
    given_the_school_can_order_devices
    given_i_cannot_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_someone_else_will_order
  end

  scenario 'when my school cannot order devices but I can' do
    given_the_school_cannot_order_devices
    given_i_can_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_that_i_cannot_order_devices_yet
  end

  scenario 'a school that cannot order devices yet' do
    given_the_school_cannot_order_devices
    given_i_can_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_that_i_will_be_able_to_order_soon
  end

  scenario 'when my school cannot order devices and I cannot order devices' do
    given_the_school_cannot_order_devices
    given_i_cannot_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_that_the_school_cannot_order_devices_yet
  end

  def given_i_am_signed_in_as_a_school_user
    sign_in_as @school_user
  end

  def given_i_can_order_devices
    @school_user = create(:school_user,
                          school:,
                          full_name: 'AAA Smith',
                          orders_devices: true,
                          techsource_account_confirmed_at: 1.second.ago)
  end

  def given_i_am_awaiting_my_techsource_account
    @school_user = create(:school_user,
                          school:,
                          full_name: 'AAA Smith',
                          orders_devices: true,
                          techsource_account_confirmed_at: nil)
  end

  def given_i_cannot_order_devices
    @school_user = create(:school_user,
                          school:,
                          full_name: 'AAA Smith',
                          orders_devices: false)
  end

  def given_the_school_can_order_devices
    stub_computacenter_outgoing_api_calls
    UpdateSchoolDevicesService.new(school:,
                                   order_state: :can_order,
                                   laptop_allocation: 100,
                                   laptops_ordered: 20).call
  end

  def given_the_school_cannot_order_devices
    school.cannot_order!
  end

  def when_i_visit_the_order_devices_page
    visit order_devices_school_path(school)
    expect(page).to have_http_status(:ok)
  end

  def then_i_see_the_allocation_of_devices
    expect(page).to have_text('allocation of 100 devices')
  end

  def and_i_see_a_link_to_techsource
    expect(page).to have_link('Start now')
  end

  def then_i_see_that_i_cannot_order_devices_yet
    expect(page).to have_content('You cannot order devices yet')
  end

  def then_i_see_that_the_school_cannot_order_devices_yet
    expect(page).to have_content('Your school cannot order devices yet')
  end

  def then_i_see_that_i_will_be_able_to_order_soon
    expect(page).to have_content('Ordering will be opened for your school as soon as possible')
  end

  def then_i_see_techsource_ready_soon
    expect(page).to have_content('be able to order once your TechSource account is ready')
  end

  def then_i_see_someone_else_will_order
    expect(page).to have_content('You do not have a TechSource account')
    expect(page).to have_content('Someone else will need to place your school’s orders.')
  end
end
