require 'rails_helper'

RSpec.feature 'Managing schools from the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry', in_devices_pilot: true) }
  let(:responsible_bodies_page) { PageObjects::Support::Devices::ResponsibleBodiesPage.new }
  let(:responsible_body_page) { PageObjects::Support::Devices::ResponsibleBodyPage.new }

  scenario 'DfE users see school users' do
    given_a_responsible_body
    and_it_has_a_school_with_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_responsible_body_page
    and_i_visit_the_school_page

    then_i_see_the_school_users
  end

  scenario 'DfE users invite school contacts to prepare for ordering devices' do
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

  def and_it_has_a_school_with_users
    school = create(:school, :with_preorder_information, :with_headteacher_contact,
                    name: 'Alpha School',
                    urn: '123321',
                    responsible_body: local_authority)
    create(:school_user, school: school, full_name: 'James P. Sullivan', email_address: 'sully@alpha.sch.uk')
    create(:school_user, school: school, full_name: 'Mike Wazowski', email_address: 'mike@alpha.sch.uk')
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_visit_the_responsible_body_page
    responsible_bodies_page.load
    click_on local_authority.name
  end

  def and_i_visit_the_school_page
    click_on 'Alpha School (123321)'
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

  def then_i_see_the_school_users
    expect(page).to have_text('James P. Sullivan')
    expect(page).to have_text('sully@alpha.sch.uk')

    expect(page).to have_text('Mike Wazowski')
    expect(page).to have_text('mike@alpha.sch.uk')
  end
end
