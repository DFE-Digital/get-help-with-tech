require 'rails_helper'

RSpec.feature 'Viewing responsible body information in the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry') }
  let(:responsible_bodies_page) { PageObjects::Support::ResponsibleBodiesPage.new }
  let(:responsible_body_page) { PageObjects::Support::ResponsibleBodyPage.new }

  scenario 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_a_responsible_body_with_users
    and_it_has_some_schools

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_support_responsible_bodies_page
    and_i_visit_a_support_responsible_body_page

    then_i_can_see_the_users_assigned_to_that_responsible_body
    and_i_can_see_the_schools_managed_by_that_responsible_body
  end

  scenario 'Computacenter users see the on-boarded responsible bodies and stats about them' do
    given_a_responsible_body_with_users
    and_it_has_some_schools

    when_i_sign_in_as_a_computacenter_user
    and_i_visit_the_support_responsible_bodies_page
    and_i_visit_a_support_responsible_body_page

    then_i_only_see_the_users_assigned_to_that_responsible_body_who_have_seen_the_privacy_notice
    and_i_can_see_the_schools_managed_by_that_responsible_body
  end

  def given_a_responsible_body_with_users
    create(:user,
           full_name: 'Amy Adams',
           email_address: 'amy.adams@coventry.gov.uk',
           sign_in_count: 0,
           last_signed_in_at: nil,
           privacy_notice_seen_at: nil,
           responsible_body: local_authority)

    create(:user,
           full_name: 'Zeta Zane',
           email_address: 'zeta.zane@coventry.gov.uk',
           sign_in_count: 2,
           last_signed_in_at: Date.new(2020, 7, 1),
           privacy_notice_seen_at: Date.new(2020, 7, 1),
           responsible_body: local_authority)
  end

  def and_it_has_some_schools
    alpha = create(:school, :primary,
                   :with_std_device_allocation, :with_coms_device_allocation,
                   urn: 567_890,
                   name: 'Alpha Primary School',
                   responsible_body: local_authority)
    alpha.std_device_allocation.update!(
      allocation: 5,
      cap: 3,
      devices_ordered: 1,
    )
    alpha.coms_device_allocation.update!(
      allocation: 4,
      cap: 2,
      devices_ordered: 0,
    )

    create(:school, :secondary, :with_std_device_allocation,
           urn: 123_456,
           name: 'Beta Secondary School',
           responsible_body: local_authority)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def when_i_sign_in_as_a_computacenter_user
    sign_in_as create(:computacenter_user, is_support: true)
  end

  def and_i_visit_the_support_responsible_bodies_page
    responsible_bodies_page.load
  end

  def and_i_visit_a_support_responsible_body_page
    click_on local_authority.name
  end

  def then_i_can_see_the_users_assigned_to_that_responsible_body
    expect(responsible_body_page.users.size).to eq(2)

    first_user = responsible_body_page.users[0]
    expect(first_user).to have_text('Zeta Zane')
    expect(first_user).to have_text('zeta.zane@coventry.gov.uk')
    expect(first_user).to have_text('2') # sign-ins
    expect(first_user).to have_text('01 Jul 00:00')

    second_user = responsible_body_page.users[1]
    expect(second_user).to have_text('Amy Adams')
    expect(second_user).to have_text('amy.adams@coventry.gov.uk')
    expect(second_user).to have_text('0') # sign-ins
    expect(second_user).to have_text('Never')
  end

  def then_i_only_see_the_users_assigned_to_that_responsible_body_who_have_seen_the_privacy_notice
    expect(responsible_body_page.users.size).to eq(1)

    first_user = responsible_body_page.users[0]
    expect(first_user).to have_text('Zeta Zane')
    expect(first_user).to have_text('zeta.zane@coventry.gov.uk')
    expect(first_user).to have_text('2') # sign-ins
    expect(first_user).to have_text('01 Jul 00:00')

    expect(responsible_body_page).not_to have_text('Amy Adams')
  end

  def and_i_can_see_the_schools_managed_by_that_responsible_body
    expect(responsible_body_page.school_rows.size).to eq(2)

    first_row = responsible_body_page.school_rows[0]
    expect(first_row).to have_text('Alpha Primary School (567890)')
    expect(first_row).to have_text('Needs a contact')
    # devices
    expect(first_row).to have_text('5 allocated')
    expect(first_row).to have_text('3 caps')
    expect(first_row).to have_text('1 ordered')
    # dongles
    expect(first_row).to have_text('4 allocated')
    expect(first_row).to have_text('2 caps')
    expect(first_row).to have_text('0 ordered')

    second_row = responsible_body_page.school_rows[1]
    expect(second_row).to have_text('Needs a contact')
    expect(second_row).to have_text('Beta Secondary School (123456)')
    expect(second_row).to have_text('0 allocated')
    expect(second_row).to have_text('0 caps')
    expect(second_row).to have_text('0 ordered')
  end
end
