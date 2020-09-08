require 'rails_helper'

RSpec.feature 'Inviting schools from the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry', in_devices_pilot: true) }
  let(:responsible_bodies_page) { PageObjects::Support::Devices::ResponsibleBodiesPage.new }
  let(:responsible_body_page) { PageObjects::Support::Devices::ResponsibleBodyPage.new }

  scenario 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_a_responsible_body
    and_it_has_a_school_that_needs_to_be_contacted

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_responsible_body_page
    then_i_can_invite_the_school

    when_i_invite_the_school
    then_the_school_is_contacted
    and_i_can_no_longer_invite_the_school
  end

  def given_a_responsible_body
    local_authority
  end

  def and_it_has_a_school_that_needs_to_be_contacted
    school = create(:school, :with_preorder_information, :with_headteacher_contact,
                    name: 'Alpha School',
                    responsible_body: local_authority)
    school.preorder_information.change_who_will_order_devices!(:school)
    school.preorder_information.school_contact = school.headteacher_contact
    school.preorder_information.save!

    expect(school.preorder_information.school_will_be_contacted?).to be_truthy
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_visit_the_responsible_body_page
    responsible_bodies_page.load
    click_on local_authority.name
  end

  def then_i_can_invite_the_school
    expect(responsible_body_page.school_rows[0]).to have_button('Invite')
  end

  def when_i_invite_the_school
    responsible_body_page.school_rows[0].click_on 'Invite'
  end

  def then_the_school_is_contacted
    expect(page).to have_text('Alpha School has been invited successfully')
    expect(responsible_body_page.school_rows[0]).to have_text('School contacted')
  end

  def and_i_can_no_longer_invite_the_school
    expect(responsible_body_page.school_rows[0]).not_to have_button('Invite')
  end
end
