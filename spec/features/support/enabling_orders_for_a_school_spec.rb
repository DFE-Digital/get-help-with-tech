require 'rails_helper'

RSpec.describe 'Enabling orders for a school from the support area' do
  let(:school_details_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:enable_orders_page) { PageObjects::Support::Schools::Devices::EnableOrdersPage.new }
  let(:enable_orders_confirm_page) { PageObjects::Support::Schools::Devices::EnableOrdersConfirmPage.new }

  before do
    @computacenter_caps_api_request = stub_computacenter_outgoing_api_calls

    @school = given_a_school_with_device_and_router_allocations_that_cannot_order
    and_the_school_has_order_users_with_confirmed_techsource_accounts
    and_i_sign_in_as_a_support_user
  end

  it 'Enabling a school to place orders for their full allocation' do
    when_i_navigate_to_the_school_page_in_support
    and_i_allow_the_school_to_order_their_full_allocation_of_devices
    and_i_confirm_the_changes

    then_ordering_is_confirmed
    and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_all_devices
    and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_all_routers
    and_the_school_order_users_have_been_informed_that_they_can_order
  end

  it 'Enabling a school to place orders for specific circustances' do
    when_i_navigate_to_the_school_page_in_support
    and_i_allow_the_school_to_order_devices_for_specific_circumstances(number_of_devices: 2, number_of_routers: 3)
    and_i_confirm_the_changes

    then_the_ordering_for_specific_circumstances_is_confirmed
    and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_two_devices
    and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_three_routers
    and_the_school_order_users_have_been_informed_that_they_can_order
  end

  it 'A school cannot order any longer' do
    @school = a_school_with_a_device_allocation_that_can_order

    when_i_navigate_to_the_school_page_in_support
    and_i_stop_the_school_from_ordering_devices
    and_i_confirm_the_changes

    then_i_see_a_confirmation_that_the_school_cannot_order
    and_computacenter_device_cap_for_the_school_matches_the_devices_ordered
  end

  it 'Correcting a mistake at the confirmation stage' do
    when_i_navigate_to_the_school_page_in_support
    and_i_allow_the_school_to_order_devices_for_specific_circumstances(number_of_devices: 5)
    and_i_change_the_number_of_devices

    then_i_see_my_previously_entered_value_for_specific_circumstances(number_of_devices: 5)
  end

  it 'The Computacenter cap update fails' do
    given_the_school_has_already_ordered_more_devices_than_their_proposed_cap

    when_i_navigate_to_the_school_page_in_support
    and_i_allow_the_school_to_order_devices_for_specific_circumstances(number_of_devices: 2)
    and_i_confirm_the_changes

    then_i_see_an_error_message_relating_to_computacenter
    then_i_see_my_previously_entered_value_for_specific_circumstances(number_of_devices: 2)
  end

  def given_a_school_with_device_and_router_allocations_that_cannot_order
    create(:school, order_state: :cannot_order, computacenter_reference: 'cc_ref')
      .tap do |school|
        create(:school_device_allocation, :with_std_allocation, allocation: 50, school: school)
        create(:school_device_allocation, :with_coms_allocation, allocation: 40, school: school)
        create(:preorder_information, :does_not_need_chromebooks, :school_will_order, status: 'ready', school: school)
      end
  end

  def a_school_with_a_device_allocation_that_can_order
    create(:school, order_state: :can_order, computacenter_reference: 'cc_ref')
      .tap do |school|
        create(:school_device_allocation, :with_std_allocation, allocation: 50, cap: 50, devices_ordered: 25, school: school)
        create(:preorder_information, :does_not_need_chromebooks, :school_will_order, status: 'ready', school: school)
      end
  end

  def and_the_school_has_order_users_with_confirmed_techsource_accounts
    create_list(:school_user, 2,
                :relevant_to_computacenter,
                :with_a_confirmed_techsource_account,
                school: @school)
  end

  def given_the_school_has_already_ordered_more_devices_than_their_proposed_cap
    WebMock.reset!

    cc_failure_response = '<CapAdjustmentResponse dateTime="2020-08-21T12:30:40Z" payloadID="abc123"><HeaderResult errorDetails="Non of the records are processed" piMessageID="11111111111111111111111111111111" status="Failed"/><FailedRecords><Record capAmount="2" capType="DfE_RemainThresholdQty|Std_Device" errorDetails="New cap must be greater than or equal to used quantity" shipTO="cc_ref" status="Failed"/></FailedRecords></CapAdjustmentResponse>'

    @computacenter_caps_api_request = stub_request(:post, 'http://computacenter.example.com/')
      .to_return(status: 200, body: cc_failure_response, headers: {})
  end

  def and_i_sign_in_as_a_support_user
    sign_in_as create(:support_user)
  end

  def when_i_navigate_to_the_school_page_in_support
    visit support_school_path(@school.urn)

    expect(school_details_page).to have_text 'Can place orders?'
    expect(school_details_page).to have_link 'Change whether they can place orders'
  end

  def and_i_allow_the_school_to_order_devices_for_specific_circumstances(number_of_devices:, number_of_routers: 0)
    click_on 'Change whether they can place orders'
    expect(enable_orders_page.no).to be_checked

    enable_orders_page.yes_specific_cirumstances.choose
    enable_orders_page.how_many_devices.set(number_of_devices)
    enable_orders_page.how_many_routers.set(number_of_routers)
    enable_orders_page.continue.click

    expect(enable_orders_confirm_page).to be_displayed
    expect(enable_orders_confirm_page).to have_text 'Check your answers and confirm'
    expect(enable_orders_confirm_page.can_order_devices_row).to have_text 'They can place orders for specific circumstances'
    expect(enable_orders_confirm_page.how_many_devices_row).to have_text "Up to #{number_of_devices} from an allocation of 50"
  end

  def and_i_allow_the_school_to_order_their_full_allocation_of_devices
    click_on 'Change whether they can place orders'

    enable_orders_page.yes.choose
    enable_orders_page.continue.click

    expect(enable_orders_confirm_page).to be_displayed
    expect(enable_orders_confirm_page).to have_text 'Check your answers and confirm'
    expect(enable_orders_confirm_page.can_order_devices_row).to have_text 'They can order their full allocation because a closure or group of self-isolating children has been reported'
    expect(enable_orders_confirm_page.how_many_devices_row).to have_text 'Their full allocation of 50'
  end

  def and_i_stop_the_school_from_ordering_devices
    click_on 'Change whether they can place orders'
    expect(enable_orders_page.yes).to be_checked

    enable_orders_page.no.choose
    enable_orders_page.continue.click

    expect(enable_orders_confirm_page).to be_displayed
    expect(enable_orders_confirm_page).to have_text 'Check your answers and confirm'
    expect(enable_orders_confirm_page.can_order_devices_row).to have_text 'No, orders cannot be placed yet'
  end

  def and_i_confirm_the_changes
    click_on 'Confirm'
  end

  def then_the_ordering_for_specific_circumstances_is_confirmed
    expect(school_details_page).to have_text('We’ve saved your choices')
    expect(school_details_page.school_details['Can place orders?']).to have_text 'Yes, for specific circumstances'
  end

  def then_ordering_is_confirmed
    expect(school_details_page).to have_text('We’ve saved your choices')
    expect(school_details_page.school_details['Can place orders?']).to have_text 'Yes'
  end

  def then_i_see_a_confirmation_that_the_school_cannot_order
    expect(school_details_page).to have_text('We’ve saved your choices')
    expect(school_details_page.school_details['Devices ordered']).to have_text '25'
    expect(school_details_page.school_details['Can place orders?']).to have_text 'No'
  end

  def and_the_school_order_users_have_been_informed_that_they_can_order
    @school.users.each do |user|
      open_email(user.email_address)
      expect(current_email).to be_present
      expect(current_email.header('template-id')).to eq(Settings.govuk_notify.templates.devices.can_order_devices)
    end
  end

  def and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_two_devices
    expect(@computacenter_caps_api_request.with { |req| req.body.include?('shipTo="cc_ref" capAmount="2"') })
      .to have_been_made
  end

  def and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_three_routers
    expect(@computacenter_caps_api_request.with { |req| req.body.include?('shipTo="cc_ref" capAmount="3"') })
      .to have_been_made
  end

  def and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_all_devices
    expect(@computacenter_caps_api_request.with { |req| req.body.include?('shipTo="cc_ref" capAmount="50"') })
      .to have_been_made
  end

  def and_computacenter_device_cap_for_the_school_has_been_updated_to_allow_ordering_all_routers
    expect(@computacenter_caps_api_request.with { |req| req.body.include?('shipTo="cc_ref" capAmount="40"') })
      .to have_been_made
  end

  def and_computacenter_device_cap_for_the_school_matches_the_devices_ordered
    expect(@computacenter_caps_api_request.with { |req| req.body.include?('shipTo="cc_ref" capAmount="25"') })
      .to have_been_made
  end

  def and_i_change_the_number_of_devices
    click_on 'Change how many devices'
  end

  def then_i_see_my_previously_entered_value_for_specific_circumstances(number_of_devices:)
    expect(page).to have_text('Can they place orders?')
    expect(page.find_field('support-enable-orders-form-order-state-can-order-for-specific-circumstances-field')).to be_checked
    expect(page).to have_field('How many devices can they order?', with: number_of_devices)
  end

  def then_i_see_an_error_message_relating_to_computacenter
    expect(page).to have_text('Could not update the cap on Computacenter\'s system')
  end
end
