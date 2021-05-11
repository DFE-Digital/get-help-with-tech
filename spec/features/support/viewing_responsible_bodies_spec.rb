require 'rails_helper'

RSpec.describe 'Viewing responsible bodies in the support area', type: :feature do
  let(:responsible_bodies_page) { PageObjects::Support::ResponsibleBodiesPage.new }

  it 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_there_are_responsible_bodies_that_have_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_support_responsible_bodies_page

    then_i_can_see_the_responsible_bodies
  end

  it 'Computacenter users see the on-boarded responsible bodies and stats about them' do
    given_there_are_responsible_bodies_that_have_users

    when_i_sign_in_as_a_computacenter_user
    and_i_visit_the_support_responsible_bodies_page

    then_i_can_see_the_responsible_bodies
  end

  def given_there_are_responsible_bodies_that_have_users
    la = create(:local_authority, name: 'Coventry', who_will_order_devices: 'responsible_body')
    create(:user, responsible_body: la, sign_in_count: 0, privacy_notice_seen_at: nil)
    create(:user, responsible_body: la, sign_in_count: 2, privacy_notice_seen_at: 1.month.ago)
    school = create(:school, responsible_body: la)
    create(:preorder_information, school: school, status: 'needs_info')

    trust = create(:trust, name: 'AWESOME TRUST', who_will_order_devices: 'school')
    create(:user, responsible_body: trust, sign_in_count: 0, privacy_notice_seen_at: nil)
    school = create(:school, responsible_body: trust)
    create(:preorder_information, school: school, status: 'ready')
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def when_i_sign_in_as_a_computacenter_user
    sign_in_as create(:support_user)
  end

  def and_i_visit_the_support_responsible_bodies_page
    responsible_bodies_page.load
  end

  def then_i_can_see_the_responsible_bodies
    expect(responsible_bodies_page.responsible_body_rows.size).to eq(2)

    first_row = responsible_bodies_page.responsible_body_rows[0]
    expect(first_row).to have_text('Coventry')
    expect(first_row).to have_text('2 users')
    expect(first_row).to have_text('1 user signed in')
    expect(first_row).to have_text('Local authority')
    expect(first_row).to have_text('0')

    second_row = responsible_bodies_page.responsible_body_rows[1]
    expect(second_row).to have_text('AWESOME TRUST')
    expect(second_row).to have_text('1 user')
    expect(second_row).to have_text('0 users signed in')
    expect(second_row).to have_text('School')
    expect(second_row).to have_text('1')
  end
end
