require 'rails_helper'

RSpec.feature 'Viewing responsible bodies in the support area', type: :feature do
  let(:responsible_bodies_page) { PageObjects::Support::Devices::ResponsibleBodiesPage.new }

  scenario 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_there_are_responsible_bodies_in_the_devices_pilot_that_have_users
    and_given_there_are_responsible_bodies_not_in_the_devices_pilot

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_support_devices_responsible_bodies_page

    then_i_can_see_the_responsible_bodies_in_the_devices_pilot
    and_i_can_see_the_responsible_bodies_not_in_the_devices_pilot
  end

  def given_there_are_responsible_bodies_in_the_devices_pilot_that_have_users
    la = create(:local_authority, name: 'Coventry', in_devices_pilot: true, who_will_order_devices: 'responsible_body')
    create(:user, responsible_body: la, sign_in_count: 0)
    create(:user, responsible_body: la, sign_in_count: 2)
    school = create(:school, responsible_body: la)
    create(:preorder_information, school: school, status: 'needs_info')

    trust = create(:trust, name: 'AWESOME TRUST', in_devices_pilot: true, who_will_order_devices: 'school')
    create(:user, responsible_body: trust, sign_in_count: 0)
    school = create(:school, responsible_body: trust)
    create(:preorder_information, school: school, status: 'ready')
  end

  def and_given_there_are_responsible_bodies_not_in_the_devices_pilot
    create(:local_authority, name: 'Wandsworth', in_devices_pilot: false)
    create(:trust, name: 'ANOTHER TRUST', in_devices_pilot: false)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_visit_the_support_devices_responsible_bodies_page
    responsible_bodies_page.load
  end

  def then_i_can_see_the_responsible_bodies_in_the_devices_pilot
    expect(responsible_bodies_page.responsible_body_rows.size).to eq(4)

    first_row = responsible_bodies_page.responsible_body_rows[0]
    expect(first_row).to have_text('Coventry')
    expect(first_row).to have_text('2 users')
    expect(first_row).to have_text('1 user signed in')
    expect(first_row).to have_text('Responsible body')
    expect(first_row).to have_text('0')

    second_row = responsible_bodies_page.responsible_body_rows[3]
    expect(second_row).to have_text('AWESOME TRUST')
    expect(second_row).to have_text('1 user')
    expect(second_row).to have_text('0 users signed in')
    expect(second_row).to have_text('School')
    expect(second_row).to have_text('1')
  end

  def and_i_can_see_the_responsible_bodies_not_in_the_devices_pilot
    expect(page).to have_text('Wandsworth (not in device reserve)')
    expect(page).to have_text('ANOTHER TRUST (not in device reserve)')
  end
end
