require 'rails_helper'

RSpec.feature 'Managing schools from the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry') }
  let(:responsible_bodies_page) { PageObjects::Support::ResponsibleBodiesPage.new }
  let(:responsible_body_page) { PageObjects::Support::ResponsibleBodyPage.new }
  let(:school) { School.find_by_name('Alpha School') }
  let(:school_contact) { school.contacts.first }

  before { stub_computacenter_outgoing_api_calls }

  scenario 'DfE users see school users' do
    given_a_responsible_body
    and_it_has_a_school_with_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_responsible_body_page
    and_i_visit_the_school_page

    then_i_see_the_school_users
  end

  scenario 'Computacenter users can only see school users who have seen the privacy notice' do
    given_a_responsible_body
    and_it_has_a_school_with_users

    when_i_sign_in_as_a_computacenter_user
    and_i_visit_the_responsible_body_page
    and_i_visit_the_school_page

    then_i_see_the_school_users_who_have_seen_the_privacy_policy
    and_i_dont_see_the_school_users_who_have_not_seen_the_privacy_policy
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

  scenario 'DfE user invites school contact who is already a user on another school' do
    given_a_responsible_body
    and_it_has_a_school_that_needs_to_be_contacted
    and_the_school_contact_is_already_a_user_on_another_school

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_responsible_body_page
    then_i_can_invite_the_school

    when_i_invite_the_school
    then_the_school_is_contacted
    and_i_can_no_longer_invite_the_school
  end

  scenario 'DfE user invites school contact who is already a user on a responsible_body' do
    given_a_responsible_body
    and_it_has_a_school_that_needs_to_be_contacted
    and_the_school_contact_is_already_a_user_on_the_responsible_body

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_responsible_body_page
    then_i_can_invite_the_school

    when_i_invite_the_school
    then_the_school_is_contacted
    and_i_can_no_longer_invite_the_school
  end

  scenario 'DfE users can update school user details' do
    given_a_responsible_body
    and_it_has_a_school_with_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_responsible_body_page
    and_i_visit_the_school_page

    then_i_see_the_school_users

    when_i_click_on_the_change_link_for_the_user
    then_i_see_a_form_with_the_users_details

    when_i_try_updating_the_user_with_invalid_details
    then_i_see_error_messages

    when_i_retry_updating_the_user_with_valid_details
    then_i_see_the_school_users_with_updated_details
  end

  scenario 'DfE users can see that a school is permanently closed' do
    given_a_responsible_body
    and_it_has_a_school_with_users
    and_the_school_is_closed

    when_i_sign_in_as_a_dfe_user
    and_i_visit_the_responsible_body_page
    and_i_visit_the_school_page

    then_i_see_that_the_school_is_permanently_closed
  end

  def given_a_responsible_body
    local_authority
  end

  def and_it_has_a_school_that_needs_to_be_contacted
    school = create(:school, :with_preorder_information, :with_headteacher,
                    name: 'Alpha School',
                    responsible_body: local_authority)
    SchoolSetWhoManagesOrdersService.new(school, :school).call
    school.set_current_contact!(school.headteacher)

    expect(school.school_will_be_contacted?).to be_truthy
  end

  def and_it_has_a_school_with_users
    school = create(:school, :with_preorder_information, :with_headteacher,
                    name: 'Alpha School',
                    urn: '123321',
                    responsible_body: local_authority)
    create(:school_user, school: school, full_name: 'James P. Sullivan', email_address: 'sully@alpha.sch.uk')
    create(:school_user, school: school, full_name: 'Mike Wazowski', email_address: 'mike@alpha.sch.uk', privacy_notice_seen_at: nil)
    create(:school_user, :deleted, school: school, full_name: 'John Doe', email_address: 'john.doe@alpha.sch.uk')
  end

  def and_the_school_is_closed
    school.update! status: :closed
  end

  def and_the_school_contact_is_already_a_user_on_another_school
    other_school = create(:school, name: 'Other school', responsible_body: local_authority)
    create(:school_user, full_name: school_contact.full_name, email_address: school_contact.email_address, orders_devices: true, schools: [other_school])
  end

  def and_the_school_contact_is_already_a_user_on_the_responsible_body
    create(:local_authority_user, full_name: school_contact.full_name, email_address: school_contact.email_address, orders_devices: true, responsible_body: local_authority)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def when_i_sign_in_as_a_computacenter_user
    sign_in_as create(:computacenter_user, is_support: true)
  end

  def and_i_visit_the_responsible_body_page
    responsible_bodies_page.load
    click_on local_authority.name
  end

  def and_i_visit_the_school_page
    click_on 'Alpha School (123321)'
  end

  def then_i_can_invite_the_school
    expect(responsible_body_page.school_rows[0]).to have_link('Invite')
  end

  def when_i_invite_the_school
    responsible_body_page.school_rows[0].click_on 'Invite'
    click_on 'Invite'
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

    expect(page).to have_text('John Doe')
    expect(page).to have_text('john.doe@alpha.sch.uk')
  end

  def then_i_see_that_the_school_is_permanently_closed
    expect(page).to have_text('has permanently closed')
  end

  def then_i_see_the_school_users_who_have_seen_the_privacy_policy
    expect(page).to have_text('James P. Sullivan')
    expect(page).to have_text('sully@alpha.sch.uk')

    expect(page).to have_text('John Doe')
    expect(page).to have_text('john.doe@alpha.sch.uk')
  end

  def and_i_dont_see_the_school_users_who_have_not_seen_the_privacy_policy
    expect(page).not_to have_text('Mike Wazowski')
    expect(page).not_to have_text('mike@alpha.sch.uk')
  end

  def when_i_click_on_the_change_link_for_the_user
    click_link 'Edit user Mike Wazowski'
  end

  def then_i_see_a_form_with_the_users_details
    expect(page).to have_field('Name', with: 'Mike Wazowski')
    expect(page).to have_field('Email address', with: 'mike@alpha.sch.uk')
    expect(page).to have_field('Telephone number')
  end

  def when_i_try_updating_the_user_with_invalid_details
    fill_in 'Name', with: ''
    fill_in 'Email address', with: 'bananas'
    click_on 'Save changes'
  end

  def when_i_retry_updating_the_user_with_valid_details
    fill_in 'Name', with: 'Michael Wazowski'
    fill_in 'Email address', with: 'mwazowski@alpha.sch.uk'
    click_on 'Save changes'

    click_on 'Alpha School'
  end

  def then_i_see_the_school_users_with_updated_details
    expect(page).to have_text('James P. Sullivan')
    expect(page).to have_text('sully@alpha.sch.uk')

    expect(page).to have_text('Michael Wazowski')
    expect(page).to have_text('mwazowski@alpha.sch.uk')

    expect(page).to have_text('John Doe')
    expect(page).to have_text('john.doe@alpha.sch.uk')
  end

  def then_i_see_error_messages
    expect(page).to have_selector('h2', text: 'There is a problem')
    expect(page).to have_text('Enter the user’s full name')
    expect(page).to have_text('Enter an email address in the correct format')
  end
end
