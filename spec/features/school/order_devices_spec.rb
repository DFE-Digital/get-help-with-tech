require 'rails_helper'

RSpec.feature 'Order devices' do
  include ViewHelper

  let(:school) { create(:school, :with_std_device_allocation) }
  let(:school_user) { create(:school_user, school: school, full_name: 'AAA Smith') }

  before do
    given_i_am_signed_in_as_a_school_user
  end

  scenario 'when my school can order devices' do
    given_i_can_order_devices
    when_i_visit_the_order_devices_page
    then_i_see_the_amount_of_devices_i_can_order
    and_i_see_a_link_to_techsource
  end

  scenario 'when my school cannot order devices' do
    given_i_cannot_order_devices
    when_i_visit_the_order_devices_page
    then_i_see_that_i_cannot_order_devices_yet
  end

  def given_i_am_signed_in_as_a_school_user
    sign_in_as school_user
  end

  def given_i_can_order_devices
    school.std_device_allocation.update!(cap: 50, allocation: 100, devices_ordered: 20)
    school.can_order!
  end

  def given_i_cannot_order_devices
    school.cannot_order!
  end

  def when_i_visit_the_order_devices_page
    visit school_order_devices_path
    expect(page).to have_http_status(:ok)
  end

  def then_i_see_the_amount_of_devices_i_can_order
    expect(page).to have_text('30 devices available')
  end

  def and_i_see_a_link_to_techsource
    expect(page).to have_link('Start now')
  end

  def then_i_see_that_i_cannot_order_devices_yet
    expect(page).to have_content('You cannot order devices yet')
    expect(page).to have_link('request devices for disadvantaged children')
  end
end
