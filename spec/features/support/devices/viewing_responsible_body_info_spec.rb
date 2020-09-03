require 'rails_helper'

RSpec.feature 'Viewing responsible body information in the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry', in_devices_pilot: true) }
  let(:responsible_bodies_page) { PageObjects::Support::Devices::ResponsibleBodiesPage.new }
  let(:responsible_body_page) { PageObjects::Support::Devices::ResponsibleBodyPage.new }

  scenario 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_a_responsible_body_with_users
    and_it_has_some_schools

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_support_responsible_bodies_page
    and_i_visit_a_support_responsible_body_page

    then_i_can_see_the_users_assigned_to_that_responsible_body
    and_i_can_see_the_schools_managed_by_that_responsible_body
  end

  def given_a_responsible_body_with_users
    create(:user,
           full_name: 'Amy Adams',
           email_address: 'amy.adams@coventry.gov.uk',
           sign_in_count: 0,
           last_signed_in_at: nil,
           responsible_body: local_authority)

    create(:user,
           full_name: 'Zeta Zane',
           email_address: 'zeta.zane@coventry.gov.uk',
           sign_in_count: 2,
           last_signed_in_at: Date.new(2020, 7, 1),
           responsible_body: local_authority)
  end

  def and_it_has_some_schools
    alpha = create(:school, :primary, :with_std_device_allocation,
                   name: 'Alpha Primary School',
                   responsible_body: local_authority)
    alpha.std_device_allocation.update!(
      allocation: 5,
      cap: 3,
      devices_ordered: 1,
    )

    create(:school, :secondary, :with_std_device_allocation,
           name: 'Beta Secondary School',
           responsible_body: local_authority)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_visit_the_support_responsible_bodies_page
    responsible_bodies_page.load
  end

  def and_i_visit_a_support_responsible_body_page
    click_on local_authority.name
  end

  def then_i_can_see_the_users_assigned_to_that_responsible_body
    expect(responsible_body_page.user_rows.size).to eq(2)

    first_row = responsible_body_page.user_rows[0]
    expect(first_row).to have_text('Zeta Zane')
    expect(first_row).to have_text('zeta.zane@coventry.gov.uk')
    expect(first_row).to have_text('2') # sign-ins
    expect(first_row).to have_text('1 July 2020')

    second_row = responsible_body_page.user_rows[1]
    expect(second_row).to have_text('Amy Adams')
    expect(second_row).to have_text('amy.adams@coventry.gov.uk')
    expect(second_row).to have_text('0') # sign-ins
    expect(second_row).to have_text('Never')
  end

  def and_i_can_see_the_schools_managed_by_that_responsible_body
    expect(responsible_body_page.school_rows.size).to eq(2)

    first_row = responsible_body_page.school_rows[0]
    expect(first_row).to have_text('Alpha Primary School')
    expect(first_row).to have_text('Needs a contact')
    expect(first_row).to have_text('5') # allocations
    expect(first_row).to have_text('3') # caps
    expect(first_row).to have_text('1') # device orders

    second_row = responsible_body_page.school_rows[1]
    expect(second_row).to have_text('Needs a contact')
    expect(second_row).to have_text('Beta Secondary School')
    expect(second_row).to have_text('0') # allocations or caps or device orders
  end
end
