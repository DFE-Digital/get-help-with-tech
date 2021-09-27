require 'rails_helper'

RSpec.feature 'Viewing responsible body information in the support area', type: :feature do
  let(:local_authority) { create(:local_authority, :devolves_management, name: 'Coventry') }
  let(:local_authority_managing_centrally) { create(:trust, :manages_centrally, :vcap_feature_flag, name: 'Manchester') }

  let(:responsible_bodies_page) { PageObjects::Support::ResponsibleBodiesPage.new }
  let(:responsible_body_page) { PageObjects::Support::ResponsibleBodyPage.new }

  before do
    stub_computacenter_outgoing_api_calls
  end

  context 'when no schools are centrally managed' do
    scenario 'DfE users see the on-boarded responsible bodies and stats about them' do
      given_a_responsible_body_with_users
      and_it_has_some_schools

      when_i_sign_in_as_a_dfe_user
      and_i_visit_the_support_responsible_bodies_page
      and_i_visit_a_support_responsible_body_page

      then_i_can_see_the_users_assigned_to_that_responsible_body
      and_i_can_see_the_schools_managed_by_that_responsible_body
      and_i_can_see_the_closed_schools_managed_by_that_responsible_body
    end

    scenario 'Computacenter users see the on-boarded responsible bodies and stats about them' do
      given_a_responsible_body_with_users
      and_it_has_some_schools

      when_i_sign_in_as_a_computacenter_user
      and_i_visit_the_support_responsible_bodies_page
      and_i_visit_a_support_responsible_body_page

      then_i_only_see_the_users_assigned_to_that_responsible_body_who_have_seen_the_privacy_notice
      and_i_can_see_the_schools_managed_by_that_responsible_body
      and_i_can_see_the_closed_schools_managed_by_that_responsible_body
    end
  end

  context 'with virtual caps enabled' do
    context 'when some schools are centrally managed' do
      scenario 'DfE users see the centrally managed schools' do
        given_a_centrally_managed_responsible_body_with_users
        and_it_has_some_centrally_managed_schools

        when_i_sign_in_as_a_dfe_user
        and_i_visit_the_support_responsible_bodies_page
        and_i_visit_a_support_responsible_body_that_is_centrally_managed_page

        and_i_can_see_a_mix_of_centrally_managed_and_devolved_schools_by_that_responsible_body
        and_i_see_details_of_some_of_the_centrally_managed_schools_in_the_responsible_body
        and_i_can_see_the_closed_schools_in_the_responsible_body
      end

      scenario 'Computacenter users see the centrally managed schools' do
        given_a_centrally_managed_responsible_body_with_users
        and_it_has_some_centrally_managed_schools

        when_i_sign_in_as_a_computacenter_user
        and_i_visit_the_support_responsible_bodies_page
        and_i_visit_a_support_responsible_body_that_is_centrally_managed_page

        then_i_only_see_the_users_assigned_to_that_responsible_body_who_have_seen_the_privacy_notice
        and_i_can_see_a_mix_of_centrally_managed_and_devolved_schools_by_that_responsible_body
        and_i_see_details_of_some_of_the_centrally_managed_schools_in_the_responsible_body
        and_i_can_see_the_closed_schools_in_the_responsible_body
      end
    end

    context 'when all schools are centrally managed' do
      scenario 'DfE users see the centrally managed schools' do
        given_a_centrally_managed_responsible_body_with_users
        and_it_has_all_centrally_managed_schools

        when_i_sign_in_as_a_dfe_user
        and_i_visit_the_support_responsible_bodies_page
        and_i_visit_a_support_responsible_body_that_is_centrally_managed_page

        and_i_can_see_the_schools_that_are_all_centrally_managed_by_that_responsible_body
        and_i_see_details_of_all_the_centrally_managed_schools_in_the_responsible_body
        and_i_can_see_the_closed_schools_in_the_responsible_body
      end

      scenario 'Computacenter users see the centrally managed schools' do
        given_a_centrally_managed_responsible_body_with_users
        and_it_has_all_centrally_managed_schools

        when_i_sign_in_as_a_computacenter_user
        and_i_visit_the_support_responsible_bodies_page
        and_i_visit_a_support_responsible_body_that_is_centrally_managed_page

        then_i_only_see_the_users_assigned_to_that_responsible_body_who_have_seen_the_privacy_notice
        and_i_can_see_the_schools_that_are_all_centrally_managed_by_that_responsible_body
        and_i_see_details_of_all_the_centrally_managed_schools_in_the_responsible_body
        and_i_can_see_the_closed_schools_in_the_responsible_body
      end
    end
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

    create(:user,
           :deleted,
           full_name: 'John Doe',
           email_address: 'john.doe@coventry.gov.uk',
           sign_in_count: 1,
           last_signed_in_at: Date.new(2020, 5, 1),
           privacy_notice_seen_at: Date.new(2020, 5, 1),
           responsible_body: local_authority)
  end

  def given_a_centrally_managed_responsible_body_with_users
    create(:user,
           full_name: 'Amy Adams',
           email_address: 'amy.adams@coventry.gov.uk',
           sign_in_count: 0,
           last_signed_in_at: nil,
           privacy_notice_seen_at: nil,
           responsible_body: local_authority_managing_centrally)

    create(:user,
           full_name: 'Zeta Zane',
           email_address: 'zeta.zane@coventry.gov.uk',
           sign_in_count: 2,
           last_signed_in_at: Date.new(2020, 7, 1),
           privacy_notice_seen_at: Date.new(2020, 7, 1),
           responsible_body: local_authority_managing_centrally)

    create(:user,
           :deleted,
           full_name: 'John Doe',
           email_address: 'john.doe@coventry.gov.uk',
           sign_in_count: 1,
           last_signed_in_at: Date.new(2020, 5, 1),
           privacy_notice_seen_at: Date.new(2020, 5, 1),
           responsible_body: local_authority_managing_centrally)
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

    closed = create(:school, :secondary,
                    :with_std_device_allocation, :with_coms_device_allocation,
                    urn: 111_222,
                    name: 'The Closed Institute',
                    status: 'closed',
                    responsible_body: local_authority)
    closed.std_device_allocation.update!(allocation: 10, cap: 2, devices_ordered: 2)
    closed.coms_device_allocation.update!(allocation: 4, cap: 4, devices_ordered: 4)
    create(:preorder_information, :school_will_order, school: closed)
    closed.users << create(:user)
  end

  def and_it_has_some_centrally_managed_schools
    alpha = create(:school, :primary,
                   :with_std_device_allocation, :with_coms_device_allocation,
                   urn: 567_891,
                   name: 'Alpha Primary School',
                   responsible_body: local_authority_managing_centrally)
    create(:preorder_information, :rb_will_order, school: alpha)

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
    alpha.can_order!

    closed = create(:school, :secondary,
                    :with_std_device_allocation, :with_coms_device_allocation,
                    urn: 111_222,
                    name: 'The Closed Institute',
                    responsible_body: local_authority_managing_centrally)
    closed.std_device_allocation.update!(allocation: 10, cap: 2, devices_ordered: 2)
    closed.coms_device_allocation.update!(allocation: 4, cap: 4, devices_ordered: 0)
    create(:preorder_information, :rb_will_order, school: closed)
    closed.can_order!

    AddSchoolToVirtualCapPoolService.new(alpha).call
    AddSchoolToVirtualCapPoolService.new(closed).call
    local_authority_managing_centrally.reload

    closed.gias_status_closed!

    # Devolved:
    beta = create(:school, :secondary,
                  :with_std_device_allocation, :with_coms_device_allocation,
                  urn: 123_457,
                  name: 'Beta Secondary School',
                  responsible_body: local_authority_managing_centrally)
    create(:preorder_information, :school_will_order, school: beta)

    beta.std_device_allocation.update!(
      allocation: 5,
      cap: 3,
      devices_ordered: 1,
    )
    beta.coms_device_allocation.update!(
      allocation: 4,
      cap: 2,
      devices_ordered: 0,
    )
    beta.can_order!
  end

  def and_it_has_all_centrally_managed_schools
    alpha = create(:school, :primary,
                   :with_std_device_allocation, :with_coms_device_allocation,
                   urn: 567_891,
                   name: 'Alpha Primary School',
                   responsible_body: local_authority_managing_centrally)
    create(:preorder_information, :rb_will_order, school: alpha)

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

    beta = create(:school, :secondary,
                  :with_std_device_allocation, :with_coms_device_allocation,
                  urn: 123_457,
                  name: 'Beta Secondary School',
                  responsible_body: local_authority_managing_centrally)
    create(:preorder_information, :rb_will_order, school: beta)

    beta.std_device_allocation.update!(
      allocation: 5,
      cap: 3,
      devices_ordered: 1,
    )
    beta.coms_device_allocation.update!(
      allocation: 4,
      cap: 2,
      devices_ordered: 0,
    )

    closed = create(:school, :secondary,
                    :with_std_device_allocation, :with_coms_device_allocation,
                    urn: 111_222,
                    name: 'The Closed Institute',
                    responsible_body: local_authority_managing_centrally)
    closed.std_device_allocation.update!(allocation: 10, cap: 2, devices_ordered: 2)
    closed.coms_device_allocation.update!(allocation: 4, cap: 4, devices_ordered: 0)
    create(:preorder_information, :rb_will_order, school: closed)

    alpha.can_order!
    beta.can_order!
    closed.can_order!
    AddSchoolToVirtualCapPoolService.new(alpha).call
    AddSchoolToVirtualCapPoolService.new(beta).call
    AddSchoolToVirtualCapPoolService.new(closed).call
    local_authority_managing_centrally.reload

    closed.gias_status_closed!
    local_authority_managing_centrally.calculate_virtual_caps!
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

  def and_i_visit_a_support_responsible_body_that_is_centrally_managed_page
    click_on local_authority_managing_centrally.name
  end

  def then_i_can_see_the_users_assigned_to_that_responsible_body
    expect(responsible_body_page.users.size).to eq(3)

    first_user = responsible_body_page.users[0]
    expect(first_user).to have_text('Zeta Zane')
    expect(first_user).to have_text('zeta.zane@coventry.gov.uk')
    expect(first_user).to have_text('2') # sign-ins
    expect(first_user).to have_text('01 Jul 00:00')

    second_user = responsible_body_page.users[1]
    expect(second_user).to have_text('John Doe')
    expect(second_user).to have_text('john.doe@coventry.gov.uk')
    expect(second_user).to have_text('1') # sign-ins
    expect(second_user).to have_text('01 May 00:00')

    third_user = responsible_body_page.users[2]
    expect(third_user).to have_text('Amy Adams')
    expect(third_user).to have_text('amy.adams@coventry.gov.uk')
    expect(third_user).to have_text('0') # sign-ins
    expect(third_user).to have_text('Never')
  end

  def then_i_only_see_the_users_assigned_to_that_responsible_body_who_have_seen_the_privacy_notice
    expect(responsible_body_page.users.size).to eq(2)

    first_user = responsible_body_page.users[0]
    expect(first_user).to have_text('Zeta Zane')
    expect(first_user).to have_text('zeta.zane@coventry.gov.uk')
    expect(first_user).to have_text('2') # sign-ins
    expect(first_user).to have_text('01 Jul 00:00')

    first_user = responsible_body_page.users[1]
    expect(first_user).to have_text('John Doe')
    expect(first_user).to have_text('john.doe@coventry.gov.uk')
    expect(first_user).to have_text('1') # sign-ins
    expect(first_user).to have_text('01 May 00:00')

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
    expect(first_row).to have_text('School')

    second_row = responsible_body_page.school_rows[1]
    expect(second_row).to have_text('Needs a contact')
    expect(second_row).to have_text('Beta Secondary School (123456)')
    expect(second_row).to have_text('0 allocated')
    expect(second_row).to have_text('0 caps')
    expect(second_row).to have_text('0 ordered')
    expect(second_row).to have_text('School')
  end

  def and_i_can_see_the_closed_schools_managed_by_that_responsible_body
    expect(responsible_body_page.closed_school_rows.size).to eq(1)

    first_row = responsible_body_page.closed_school_rows[0]
    expect(first_row).to have_text('The Closed Institute (111222)')
    expect(first_row).to have_text('Not applicable')
    # devices
    expect(first_row).to have_text('10 allocated')
    expect(first_row).to have_text('2 caps')
    expect(first_row).to have_text('2 ordered')
    # dongles
    expect(first_row).to have_text('4 allocated')
    expect(first_row).to have_text('4 caps')
    expect(first_row).to have_text('4 ordered')
    expect(first_row).to have_text('School or college')
    # users
    expect(first_row).to have_text('1 user')
  end

  # some:
  def and_i_can_see_a_mix_of_centrally_managed_and_devolved_schools_by_that_responsible_body
    expect(responsible_body_page.school_rows.size).to eq(2)

    first_row = responsible_body_page.school_rows[0]
    expect(first_row).to have_text('Alpha Primary School (567891)')
    # devices
    expect(first_row).to have_text('5 allocated')
    expect(first_row).not_to have_text('3 caps')
    expect(first_row).not_to have_text('1 ordered')
    # dongles
    expect(first_row).to have_text('4 allocated')
    expect(first_row).not_to have_text('2 caps')
    expect(first_row).not_to have_text('0 ordered')

    expect(first_row).to have_text('Trust')

    second_row = responsible_body_page.school_rows[1]
    expect(second_row).to have_text('Beta Secondary School (123457)')

    # devices
    expect(second_row).to have_text('5 allocated')
    expect(second_row).to have_text('3 caps')
    expect(second_row).to have_text('1 ordered')
    # dongles
    expect(second_row).to have_text('4 allocated')
    expect(second_row).to have_text('2 caps')
    expect(second_row).to have_text('0 ordered')

    expect(second_row).to have_text('School')
  end

  def and_i_see_details_of_some_of_the_centrally_managed_schools_in_the_responsible_body
    stats = responsible_body_page.centrally_managed_stats

    expect(stats[0]).to have_text('manages ordering for 1 of 2 of its schools')
    expect(stats[1]).to have_text('has 2 devices and 6 routers available')
    expect(stats[2]).to have_text('has ordered 3 devices and 0 routers')
  end

  def and_i_can_see_the_closed_schools_in_the_responsible_body
    expect(responsible_body_page.closed_school_rows.size).to eq(1)

    first_row = responsible_body_page.closed_school_rows[0]
    expect(first_row).to have_text('The Closed Institute (111222)')
    expect(first_row).to have_text('In pool')
    # devices
    expect(first_row).to have_text('10 allocated')
    expect(first_row).to have_text('2 caps')
    expect(first_row).to have_text('2 ordered')
    # dongles
    expect(first_row).to have_text('4 allocated')
    expect(first_row).to have_text('4 caps')
    expect(first_row).to have_text('0 ordered')
    expect(first_row).to have_text('Trust')
    # users
    expect(first_row).to have_text('No users')
  end

  # all:
  def and_i_can_see_the_schools_that_are_all_centrally_managed_by_that_responsible_body
    expect(responsible_body_page.school_rows.size).to eq(2)

    first_row = responsible_body_page.school_rows[0]
    expect(first_row).to have_text('Alpha Primary School (567891)')
    # devices
    expect(first_row).to have_text('5 allocated')
    expect(first_row).not_to have_text('3 caps')
    expect(first_row).not_to have_text('1 ordered')
    # dongles
    expect(first_row).to have_text('4 allocated')
    expect(first_row).not_to have_text('2 caps')
    expect(first_row).not_to have_text('0 ordered')
    expect(first_row).to have_text('Trust')

    second_row = responsible_body_page.school_rows[1]
    expect(second_row).to have_text('Beta Secondary School (123457)')

    # devices
    expect(second_row).to have_text('5 allocated')
    expect(second_row).not_to have_text('3 caps')
    expect(second_row).not_to have_text('1 ordered')
    # dongles
    expect(second_row).to have_text('4 allocated')
    expect(second_row).not_to have_text('2 caps')
    expect(second_row).not_to have_text('0 ordered')

    expect(second_row).to have_text('Trust')
  end

  def and_i_see_details_of_all_the_centrally_managed_schools_in_the_responsible_body
    stats = responsible_body_page.centrally_managed_stats

    expect(stats[0]).to have_text('manages ordering for all of its schools')
    expect(stats[1]).to have_text('has 4 devices and 8 routers available')
    expect(stats[2]).to have_text('has ordered 4 devices and 0 routers')
  end
end
