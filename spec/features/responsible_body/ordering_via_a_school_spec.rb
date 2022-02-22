require 'rails_helper'

RSpec.feature 'Ordering via a school' do
  let(:rb) { create(:local_authority, schools: [school]) }
  let(:rb_user) { create(:local_authority_user, responsible_body: rb) }
  let(:another_school) do
    create(:school,
           :centrally_managed,
           :does_not_need_chromebooks,
           school_contact: school.contacts.first,
           laptops: [12, 12, 3])
  end
  let(:school) do
    create(:school,
           :centrally_managed,
           :with_headteacher,
           :does_not_need_chromebooks)
  end
  let(:school_page) { PageObjects::ResponsibleBody::SchoolPage.new }
  let(:school_order_devices_page) { PageObjects::ResponsibleBody::SchoolOrderDevicesPage.new }

  context 'when the school is not in a virtual cap pool' do
    before do
      allow(school).to receive(:vcap?).and_return(false)
    end

    context 'when school has no devices to order' do
      scenario 'cannot order devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        and_i_see_the_no_allocation_message
      end
    end

    context 'when school has devices to order' do
      before do
        stub_computacenter_outgoing_api_calls
        UpdateSchoolDevicesService.new(school:,
                                       order_state: :can_order,
                                       laptop_allocation: 12,
                                       laptops_ordered: 3).call
      end

      scenario 'can order devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        and_i_see 'Devices ordered'
        and_i_see '3 devices'
      end
    end
  end

  context 'when the school is in a virtual cap pool' do
    let(:rb) { create(:trust, :manages_centrally, :vcap, schools: [school]) }

    context 'when school has no devices to order' do
      scenario 'cannot order devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        and_i_do_not_see 'This school had no allocation'
        and_i_do_not_see 'Order devices now'
      end
    end

    context 'when the school can order devices and has an allocation' do
      before do
        stub_computacenter_outgoing_api_calls
        UpdateSchoolDevicesService.new(school:,
                                       order_state: 'can_order',
                                       laptop_allocation: 12,
                                       laptops_ordered: 3).call
      end

      scenario 'I do not see the number of devices' do
        given_i_am_signed_in_as_rb_user

        when_i_view_a_school(school)
        then_i_do_not_see 'You’ve ordered 3 of 10 devices'
        and_i_do_not_see 'Devices ordered'
        and_i_do_not_see '3 devices'
      end
    end
  end

  def given_i_am_signed_in_as_rb_user
    sign_in_as rb_user
  end

  def when_i_view_a_school(school)
    school_page.load(urn: school.urn)
  end

  def when_i_choose_to_order_devices
    page.click_link 'Order devices', class: 'govuk-button'
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
    expect(page).to have_content 'This school had no allocation'
  end
end
