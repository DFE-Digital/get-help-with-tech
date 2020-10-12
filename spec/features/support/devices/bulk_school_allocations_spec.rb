require 'rails_helper'

RSpec.feature 'Allowing multiple schools to order their full allocation' do
  let(:support_user) { create(:support_user) }
  let(:schools) { create_list(:school, 3, :with_std_device_allocation, order_state: :cannot_order) }
  let(:bad_urn) { '12492903' }

  before do
    allow_computacenter_outgoing_api_calls
  end

  scenario 'visiting the full allocations page' do
    given_i_am_signed_in_as_a_support_user
    when_i_click_on_the_full_allocations_nav_menu_link
    then_i_see_the_full_allocations_page
  end

  scenario 'submitting URNs for schools that need their full allocation' do
    given_i_am_signed_in_as_a_support_user
    when_i_navigate_to_the_full_allocations_page
    and_i_enter_my_school_urns
    and_i_click_the_enable_full_allocations_button
    then_i_see_a_summary_page
  end

  scenario 'submitting URNs for schools that includes bad data' do
    given_i_am_signed_in_as_a_support_user
    when_i_navigate_to_the_full_allocations_page
    and_i_enter_my_school_urns_with_bad_data
    and_i_click_the_enable_full_allocations_button
    then_i_see_a_summary_page_with_error_messages
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def when_i_click_on_the_full_allocations_nav_menu_link
    click_link 'Full allocations'
  end

  def then_i_see_the_full_allocations_page
    expect(page).to have_selector('h1', text: 'Allow schools to order their full allocation')
  end

  def when_i_navigate_to_the_full_allocations_page
    visit new_support_devices_school_bulk_allocation_path
  end

  def and_i_enter_my_school_urns
    fill_in 'Enter one school URN per line', with: schools.map(&:urn).join("\r\n")
  end

  def and_i_enter_my_school_urns_with_bad_data
    data = schools.map(&:urn).append(bad_urn).join("\r\n")
    fill_in 'Enter one school URN per line', with: data
  end

  def and_i_click_the_enable_full_allocations_button
    click_on 'Enable full allocations'
  end

  def then_i_see_a_summary_page
    expect(page).to have_selector('h1', text: 'Bulk allocation summary')
    expect(page).to have_text("#{schools.count} allocated successfully")
    schools.each do |school|
      expect(page).to have_selector('td', text: school.urn)
      expect(page).to have_selector('td', text: school.name)
    end
  end

  def then_i_see_a_summary_page_with_error_messages
    expect(page).to have_selector('h1', text: 'Bulk allocation summary')
    expect(page).to have_text("#{schools.count} allocated successfully")
    expect(page).to have_text('1 error')
    schools.each do |school|
      expect(page).to have_selector('td', text: school.urn)
      expect(page).to have_selector('td', text: school.name)
    end
    expect(page).to have_selector('td', text: bad_urn)
    expect(page).to have_selector('td', text: 'URN not found')
  end
end
