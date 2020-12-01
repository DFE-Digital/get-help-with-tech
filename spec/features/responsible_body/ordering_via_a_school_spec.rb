require 'rails_helper'

RSpec.feature 'Ordering via a school' do
  let(:rb) { create(:local_authority, schools: [school, school_that_cannot_order_as_reopened]) }
  let(:rb_user) { create(:local_authority_user, responsible_body: rb) }
  let(:preorder) { create(:preorder_information, :rb_will_order, :does_not_need_chromebooks, school_contact: school.contacts.first) }
  let(:another_preorder) { create(:preorder_information, :rb_will_order, :does_not_need_chromebooks, school_contact: school.contacts.first) }
  let(:another_allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices, devices_ordered: 3, cap: 12) }
  let(:school) { create(:school, :with_headteacher_contact) }
  let(:school_that_cannot_order_as_reopened) { create(:school, :with_headteacher_contact, order_state: :cannot_order_as_reopened) }

  let(:school_page) { PageObjects::ResponsibleBody::SchoolPage.new }
  let(:school_order_devices_page) { PageObjects::ResponsibleBody::SchoolOrderDevicesPage.new }

  before do
    school.update!(preorder_information: preorder)
    school_that_cannot_order_as_reopened.update!(preorder_information: another_preorder, std_device_allocation: another_allocation)
  end

  context 'when the responsible body does not the vcap_feature_flag enabled' do
    context 'when school has no devices to order' do
      scenario 'cannot order devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        then_i_see_status_of('Ready')
        and_i_see_the_no_allocation_message
      end
    end

    scenario 'when the school has reopened' do
      given_i_am_signed_in_as_rb_user

      when_i_view_a_school(school_that_cannot_order_as_reopened)
      then_i_see('You ordered 3 of 12 devices')
    end

    context 'when school has devices to order' do
      let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices, cap: 12, devices_ordered: 3) }

      before do
        school.update!(std_device_allocation: allocation, order_state: 'can_order')
        school.preorder_information.refresh_status!
      end

      scenario 'can order devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        then_i_see_status_of('You can order')
        and_i_see 'You’ve ordered 3 of 12 devices'

        when_i_click_on('Order devices')
        then_i_see_the_school_order_devices_page
        and_i_see_the_techsource_button
      end
    end
  end

  context 'when the virtual_caps feature flag is active and responsible body does have the vcap_feature_flag enabled', with_feature_flags: { virtual_caps: 'active' } do
    let(:rb) { create(:trust, :vcap_feature_flag, schools: [school, school_that_cannot_order_as_reopened]) }

    context 'when school has no devices to order' do
      scenario 'cannot order devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        then_i_see_status_of('Ready')
        and_i_do_not_see 'This school has no allocation'
        and_i_do_not_see 'Order devices now'
      end
    end

    scenario 'when the school has reopened' do
      given_i_am_signed_in_as_rb_user

      when_i_view_a_school(school_that_cannot_order_as_reopened)
      and_i_do_not_see('You ordered 3 of 12 devices')
      and_i_do_not_see 'Order devices now'
    end

    context 'when the school can order devices and has an allocation' do
      let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices, allocation: 12, cap: 10, devices_ordered: 3) }

      before do
        school.update!(std_device_allocation: allocation, order_state: 'can_order')
        school.preorder_information.refresh_status!
      end

      scenario 'I do not see the number of devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        then_i_do_not_see 'You’ve ordered 3 of 10 devices'
        and_i_see_an_order_devices_now_link
      end
    end
  end

  def given_i_am_signed_in_as_rb_user
    sign_in_as rb_user
  end

  def when_i_view_a_school(school)
    school_page.load(urn: school.urn)
  end

  def then_i_see_status_of(status)
    expect(school_page.school_details).to have_content(status)
  end

  def when_i_click_on(text)
    page.click_on text
  end

  def then_i_see_the_school_order_devices_page
    expect(school_order_devices_page).to be_displayed
  end

  def and_i_see_the_techsource_button
    expect(school_order_devices_page).to have_techsource_button
  end

  def then_i_see(content)
    expect(page).to have_content(content)
  end
  alias_method :and_i_see, :then_i_see

  def then_i_do_not_see(content)
    expect(page).not_to have_content(content)
  end
  alias_method :and_i_do_not_see, :then_i_do_not_see

  def and_i_do_not_see_an_order_devices_link
    expect(page).not_to have_link('Order devices')
  end

  def and_i_see_that_all_devices_are_ordered
    expect(page).to have_content('All devices ordered')
  end

  def and_i_see_the_no_allocation_message
    expect(page).to have_content 'This school has no allocation'
  end

  def and_i_see_an_order_devices_now_link
    expect(page).to have_link('Order devices now')
  end
end
