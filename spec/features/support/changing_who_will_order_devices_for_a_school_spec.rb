require 'rails_helper'

RSpec.feature 'Changing who will order devices for a school' do
  let(:school_details_page) { PageObjects::Support::SchoolDetailsPage.new }

  before do
    stub_computacenter_outgoing_api_calls
    given_i_sign_in_as_a_support_user
  end

  scenario 'setting school will order devices when responsible body does not have vcap feature flag' do
    given_a_responsible_body_without_virtual_caps_enabled
    given_a_school_that_is_centrally_managed

    when_i_navigate_to_the_school_page_in_support
    and_i_click_the_change_link_for_who_will_order
    then_i_do_not_see_content_warning_that_the_change_is_irreversible

    when_i_change_who_will_order_to_the_school
    then_the_who_will_order_details_show_that_the_school_orders_in_the_support_console
  end

  scenario 'setting responsible body will order devices when responsible body does not have vcap feature flag' do
    given_a_responsible_body_without_virtual_caps_enabled
    given_a_school_that_manages_orders

    when_i_navigate_to_the_school_page_in_support
    and_i_click_the_change_link_for_who_will_order
    then_i_do_not_see_content_warning_that_the_change_is_irreversible

    when_i_change_who_will_order_to_the_responsible_body
    then_the_who_will_order_details_show_that_the_responsible_body_orders_in_the_support_console
  end

  scenario 'setting school will order devices when responsible body has vcap feature flag' do
    given_a_responsible_body_with_virtual_caps_enabled
    given_a_school_that_is_centrally_managed

    when_i_navigate_to_the_school_page_in_support
    then_i_cannot_see_the_change_link_for_who_will_order
  end

  scenario 'setting responsible body will order devices when responsible body has vcap feature flag' do
    given_a_responsible_body_with_virtual_caps_enabled
    given_a_school_that_manages_orders

    when_i_navigate_to_the_school_page_in_support
    and_i_click_the_change_link_for_who_will_order
    then_i_see_content_warning_that_the_change_is_irreversible

    when_i_change_who_will_order_to_the_responsible_body
    then_the_who_will_order_details_show_that_the_responsible_body_orders_in_the_support_console
    and_i_cannot_see_the_change_link_for_who_will_order
  end

  def given_i_sign_in_as_a_support_user
    sign_in_as create(:support_user)
  end

  def given_a_responsible_body_without_virtual_caps_enabled
    @local_authority = create(:local_authority, :manages_centrally, vcap_feature_flag: false)
  end

  def given_a_responsible_body_with_virtual_caps_enabled
    @local_authority = create(:local_authority, :manages_centrally, vcap_feature_flag: true)
  end

  def given_a_school_that_is_centrally_managed
    @school = create(:school, :centrally_managed, :with_std_device_allocation, responsible_body: @local_authority)
  end

  def given_a_school_that_manages_orders
    @school = create(:school, :manages_orders, :with_std_device_allocation, responsible_body: @local_authority)
  end

  def when_i_navigate_to_the_school_page_in_support
    visit support_school_path(@school.urn)
    expect(school_details_page).to be_displayed
  end

  def and_i_click_the_change_link_for_who_will_order
    school_details_page
      .school_details['Who will order?']
      .follow_action_link
  end

  def when_i_change_who_will_order_to_the_school
    choose 'The school will place their own orders'
    click_on 'Continue'
  end

  def when_i_change_who_will_order_to_the_responsible_body
    choose 'Orders will be placed centrally'
    click_on 'Continue'
  end

  def then_i_do_not_see_content_warning_that_the_change_is_irreversible
    expect(page).not_to have_text('You will not be able to transfer back ordering responsibility to the school once you’ve decided to do it this way')
  end

  def then_i_see_content_warning_that_the_change_is_irreversible
    expect(page).to have_text('You will not be able to transfer back ordering responsibility to the school once you’ve decided to do it this way')
  end

  def then_the_who_will_order_details_show_that_the_school_orders_in_the_support_console
    expect(school_details_page.school_details['Who will order?'].value).to eq('The school or college orders devices')
  end

  def then_the_who_will_order_details_show_that_the_responsible_body_orders_in_the_support_console
    expect(school_details_page.school_details['Who will order?'].value).to eq('The local authority orders devices')
  end

  def then_i_cannot_see_the_change_link_for_who_will_order
    expect(school_details_page.school_details['Who will order?']).not_to have_link('Change')
  end

  alias_method :and_i_cannot_see_the_change_link_for_who_will_order, :then_i_cannot_see_the_change_link_for_who_will_order
end
