require 'rails_helper'

RSpec.describe 'Computacenter confirming TechSource accounts' do
  scenario 'when school user + school can order devices' do
    given_school_exists_that_can_order_devices
    and_school_user_awaiting_techsource_confirmation
    and_a_computacenter_user_exists

    when_a_computacenter_user_logs_in
    and_confirms_techsource_accounts(@school_user)
    then_it_sends_an_email_to_the_user(@school_user)

    when_a_support_user_logs_in
    and_navigates_to_the_school_page
    then_an_email_audit_entry_is_present
  end

  scenario 'when rb user + rbs schools can order devices' do
    given_rb_exists_that_can_order_devices
    and_rb_user_awaiting_techsource_confirmation
    and_a_computacenter_user_exists

    when_a_computacenter_user_logs_in
    and_confirms_techsource_accounts(@rb_user)
    then_it_sends_an_email_to_the_user(@rb_user)
  end

  scenario 'when school user + school cannot order devices' do
    given_school_exists_that_cannot_order_devices
    and_school_user_awaiting_techsource_confirmation
    and_a_computacenter_user_exists

    when_a_computacenter_user_logs_in
    and_confirms_techsource_accounts(@school_user)
    then_it_does_not_send_an_email_to_the_user
  end

  def given_rb_exists_that_can_order_devices
    allocation = create(:school_device_allocation, :with_std_allocation, :with_orderable_devices)
    preorder = create(:preorder_information, who_will_order_devices: 'responsible_body')
    @rb = create(:trust)
    @school = create(:school,
                     responsible_body: @rb,
                     preorder_information: preorder,
                     order_state: :can_order,
                     std_device_allocation: allocation)
  end

  def given_school_exists_that_can_order_devices
    allocation = create(:school_device_allocation, :with_std_allocation, :with_orderable_devices)
    preorder = create(:preorder_information, :does_not_need_chromebooks, who_will_order_devices: 'school', status: :school_can_order)
    @school = create(:school, preorder_information: preorder, order_state: :can_order, std_device_allocation: allocation)
    @school.users << create(:school_user)
    expect(preorder.status).to eq('school_can_order')
  end

  def given_school_exists_that_cannot_order_devices
    allocation = create(:school_device_allocation, :with_std_allocation)
    preorder = create(:preorder_information, who_will_order_devices: 'school')
    @school = create(:school, preorder_information: preorder, order_state: :can_order, std_device_allocation: allocation)
  end

  def and_school_user_awaiting_techsource_confirmation
    @school_user = create(:school_user,
                          school: @school,
                          orders_devices: true)
  end

  def and_rb_user_awaiting_techsource_confirmation
    @rb_user = create(:trust_user,
                      responsible_body: @rb,
                      orders_devices: true)
  end

  def and_a_computacenter_user_exists
    @computacenter_user = create(:computacenter_user)
  end

  def when_a_computacenter_user_logs_in
    sign_in_as @computacenter_user
  end

  def when_a_support_user_logs_in
    sign_in_as create(:support_user)
  end

  def and_confirms_techsource_accounts(user)
    techsource_page = PageObjects::Computacenter::TechSourcePage.new
    techsource_page.load
    techsource_page.bulk_email_input.set(user.email_address)
    techsource_page.continue.click
  end

  def and_navigates_to_the_school_page
    school_page = PageObjects::Support::SchoolDetailsPage.new
    school_page.load(urn: @school.urn)
  end

  def then_it_sends_an_email_to_the_user(user)
    email = ActionMailer::Base.deliveries.last
    expect(email.to_addrs).to include(user.email_address)
  end

  def then_it_does_not_send_an_email_to_the_user
    email = ActionMailer::Base.deliveries.last
    expect(email).to be_nil
  end

  def then_an_email_audit_entry_is_present
    expect(page.text).to include("#{@school_user.full_name} <#{@school_user.email_address}>")
  end
end
