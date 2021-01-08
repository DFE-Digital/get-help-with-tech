require 'rails_helper'

RSpec.feature 'Order devices' do
  include ViewHelper

  let(:school) { create(:school, :with_std_device_allocation) }

  scenario 'when my school can order devices and I can order devices' do
    given_the_school_can_order_devices
    given_i_can_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_the_amount_of_devices_i_can_order
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

  context 'when there’s a national lockdown', with_feature_flags: { schools_closed_for_national_lockdown: 'active' } do
    scenario 'a school that cannot order devices yet' do
      given_the_school_cannot_order_devices
      given_i_can_order_devices
      given_i_am_signed_in_as_a_school_user

      when_i_visit_the_order_devices_page
      then_i_see_that_i_will_be_able_to_order_soon
    end
  end

  scenario 'when my school cannot order devices and I cannot order devices' do
    given_the_school_cannot_order_devices
    given_i_cannot_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_that_the_school_cannot_order_devices_yet
  end

  scenario 'when my reopened school cannot order devices but I can' do
    given_the_school_cannot_order_devices_as_reopened
    given_i_can_order_devices
    given_i_am_signed_in_as_a_school_user

    when_i_visit_the_order_devices_page
    then_i_see_that_i_cannot_order_as_school_reopened
  end

  def given_i_am_signed_in_as_a_school_user
    sign_in_as @school_user
  end

  def given_i_can_order_devices
    @school_user = create(:school_user,
                          school: school,
                          full_name: 'AAA Smith',
                          orders_devices: true,
                          techsource_account_confirmed_at: 1.second.ago)
  end

  def given_i_am_awaiting_my_techsource_account
    @school_user = create(:school_user,
                          school: school,
                          full_name: 'AAA Smith',
                          orders_devices: true,
                          techsource_account_confirmed_at: nil)
  end

  def given_i_cannot_order_devices
    @school_user = create(:school_user,
                          school: school,
                          full_name: 'AAA Smith',
                          orders_devices: false)
  end

  def given_the_school_can_order_devices
    school.std_device_allocation.update!(cap: 50, allocation: 100, devices_ordered: 20)
    school.can_order!
  end

  def given_the_school_cannot_order_devices
    school.cannot_order!
  end

  def given_the_school_cannot_order_devices_as_reopened
    school.cannot_order_as_reopened!
  end

  def when_i_visit_the_order_devices_page
    visit order_devices_school_path(school)
    expect(page).to have_http_status(:ok)
  end

  def then_i_see_the_amount_of_devices_i_can_order
    expect(page).to have_text('30 devices available')
  end

  def and_i_see_a_link_to_techsource
    expect(page).to have_link('Start now')
  end

  def then_i_see_that_i_cannot_order_devices_yet
    expect(page).to have_content('You cannot order your full allocation yet')
    expect(page).to have_link('request devices for disadvantaged children')
  end

  def then_i_see_that_i_cannot_order_as_school_reopened
    expect(page).to have_content('Your school has reopened and ordering has closed')
  end

  def then_i_see_that_the_school_cannot_order_devices_yet
    expect(page).to have_content('Your school cannot your full allocation yet')
    expect(page).to have_link('request devices for disadvantaged children')
  end

  def then_i_see_that_i_will_be_able_to_order_soon
    expect(page).to have_content('We’re opening orders for primary schools gradually, and will invite all to order by 13 January.')
  end

  def then_i_see_techsource_ready_soon
    expect(page).to have_content('Your TechSource account will be ready soon')
  end

  def then_i_see_someone_else_will_order
    expect(page).to have_content('You do not have a TechSource account')
    expect(page).to have_content('Someone else will need to place your school’s orders.')
  end
end
