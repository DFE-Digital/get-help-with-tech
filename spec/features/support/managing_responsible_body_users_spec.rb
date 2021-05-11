require 'rails_helper'

RSpec.describe 'Managing responsible body users in the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry') }
  let(:responsible_body_page) { PageObjects::Support::ResponsibleBodyPage.new }
  let(:invite_new_user_page) { PageObjects::Support::Users::InviteNewUserPage.new }
  let(:edit_user_page) { PageObjects::Support::Users::EditUserPage.new }

  it 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_there_is_a_responsible_body_with_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_a_support_devices_responsible_body_page
    then_i_can_see_the_responsible_body_with_users

    when_try_adding_a_new_user_with_invalid_details
    then_i_can_see_error_messages

    and_when_i_retry_adding_a_new_user_with_valid_details
    then_i_can_see_the_responsible_body_with_new_users_as_well
  end

  it 'Computacenter users see the on-boarded responsible bodies and stats about them' do
    given_there_is_a_responsible_body_with_users

    when_i_sign_in_as_a_computacenter_user
    and_i_visit_a_support_devices_responsible_body_page
    then_i_can_see_the_responsible_body
    and_i_only_see_the_users_who_have_seen_the_privacy_policy
  end

  it 'DfE users can update on-boarded responsible body users' do
    given_there_is_a_responsible_body_with_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_a_support_devices_responsible_body_page
    then_i_can_see_the_responsible_body_with_users

    when_i_try_updating_a_user_with_invalid_details
    then_i_can_see_error_messages

    when_i_retry_updating_a_user_with_valid_details
    then_i_can_see_the_responsible_body_with_the_updated_user_details
  end

  def given_there_is_a_responsible_body_with_users
    create(:user,
           full_name: 'Amy Adams',
           sign_in_count: 0,
           last_signed_in_at: nil,
           privacy_notice_seen_at: nil,
           responsible_body: local_authority)

    create(:user,
           full_name: 'Zeta Zane',
           sign_in_count: 2,
           last_signed_in_at: Date.new(2020, 7, 1),
           privacy_notice_seen_at: Date.new(2020, 7, 1),
           responsible_body: local_authority)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def when_i_sign_in_as_a_computacenter_user
    sign_in_as create(:computacenter_user, is_support: true)
  end

  def and_i_visit_a_support_devices_responsible_body_page
    responsible_body_page.load(id: local_authority.id)
  end

  def then_i_can_see_the_responsible_body_with_users
    expect(responsible_body_page.users.size).to eq(2)

    expect(responsible_body_page.users[0]).to have_text('Zeta Zane')
    expect(responsible_body_page.users[1]).to have_text('Amy Adams')
  end

  def then_i_can_see_the_responsible_body
    expect(responsible_body_page).to be_displayed
  end

  def and_i_only_see_the_users_who_have_seen_the_privacy_policy
    expect(responsible_body_page.users.size).to eq(1)

    expect(responsible_body_page.users[0]).to have_text('Zeta Zane')
    expect(responsible_body_page.users[1]).not_to have_text('Amy Adams')
  end

  def when_try_adding_a_new_user_with_invalid_details
    responsible_body_page.invite_a_new_user_link.click

    invite_new_user_page.name.set ''
    invite_new_user_page.email_address.set 'k'
    invite_new_user_page.send_invite.click
  end

  def then_i_can_see_error_messages
    expect(page).to have_text('Enter the user’s full name')
    expect(page).to have_text('Enter an email address that is at least 2 characters')
  end

  def and_when_i_retry_adding_a_new_user_with_valid_details
    invite_new_user_page.name.set 'Kate Krampton'
    invite_new_user_page.email_address.set 'kate.krampton@coventry.gov.uk'
    invite_new_user_page.send_invite.click
  end

  def then_i_can_see_the_responsible_body_with_new_users_as_well
    click_on local_authority.name

    expect(responsible_body_page.users.size).to eq(3)

    expect(responsible_body_page.users[0]).to have_text('Zeta Zane')

    second_row = responsible_body_page.users[1]
    expect(second_row).to have_text('Kate Krampton')
    expect(second_row).to have_text('kate.krampton@coventry.gov.uk')
    expect(second_row).to have_text('0') # sign-ins
    expect(second_row).to have_text('Never')

    expect(responsible_body_page.users[2]).to have_text('Amy Adams')
  end

  def when_i_try_updating_a_user_with_invalid_details
    click_link 'Edit user Amy Adams'

    edit_user_page.name.set ''
    edit_user_page.email_address.set 'a'
    edit_user_page.save_changes.click
  end

  def when_i_retry_updating_a_user_with_valid_details
    edit_user_page.name.set 'Amy Wirral'
    edit_user_page.email_address.set 'amy.wirral@coventry.gov.uk'
    edit_user_page.save_changes.click

    click_on local_authority.name
  end

  def then_i_can_see_the_responsible_body_with_the_updated_user_details
    expect(responsible_body_page.users.size).to eq(2)

    expect(responsible_body_page.users[0]).to have_text('Zeta Zane')
    expect(responsible_body_page.users[1]).to have_text('amy.wirral@coventry.gov.uk')
    expect(responsible_body_page.users[1]).to have_text('Amy Wirral')
  end
end
