require 'rails_helper'

RSpec.feature 'Adding new responsible body users in the support area', type: :feature do
  let(:local_authority) { create(:local_authority, name: 'Coventry') }
  let(:responsible_body_page) { PageObjects::Support::ResponsibleBodyPage.new }

  scenario 'DfE users see the on-boarded responsible bodies and stats about them' do
    given_there_is_a_responsible_body_with_users

    when_i_sign_in_as_a_dfe_user
    and_i_visit_a_support_responsible_body_page
    then_i_can_see_the_responsible_body_with_users

    when_try_adding_a_new_user_with_invalid_details
    then_i_can_see_error_messages

    and_when_i_retry_adding_a_new_user_with_valid_details
    then_i_can_see_the_responsible_body_with_new_users_as_well
  end

  def given_there_is_a_responsible_body_with_users
    create(:user,
           full_name: 'Amy Adams',
           sign_in_count: 0,
           last_signed_in_at: nil,
           responsible_body: local_authority)

    create(:user,
           full_name: 'Zeta Zane',
           sign_in_count: 2,
           last_signed_in_at: Date.new(2020, 7, 1),
           responsible_body: local_authority)
  end

  def when_i_sign_in_as_a_dfe_user
    sign_in_as create(:dfe_user)
  end

  def and_i_visit_a_support_responsible_body_page
    responsible_body_page.load(id: local_authority.id)
  end

  def then_i_can_see_the_responsible_body_with_users
    expect(responsible_body_page.user_rows.size).to eq(2)

    expect(responsible_body_page.user_rows[0]).to have_text('Zeta Zane')
    expect(responsible_body_page.user_rows[1]).to have_text('Amy Adams')
  end

  def when_try_adding_a_new_user_with_invalid_details
    click_on 'Add a user'

    fill_in 'Full name', with: ''
    fill_in 'Email address', with: 'k'

    click_on 'Submit'
  end

  def then_i_can_see_error_messages
    expect(page).to have_text('Enter your full name')
    expect(page).to have_text('Enter an email address that is at least 2 characters')
  end

  def and_when_i_retry_adding_a_new_user_with_valid_details
    fill_in 'Full name', with: 'Kate Krampton'
    fill_in 'Email address', with: 'kate.krampton@coventry.gov.uk'

    click_on 'Submit'
  end

  def then_i_can_see_the_responsible_body_with_new_users_as_well
    expect(responsible_body_page.user_rows.size).to eq(3)

    expect(responsible_body_page.user_rows[0]).to have_text('Zeta Zane')

    second_row = responsible_body_page.user_rows[1]
    expect(second_row).to have_text('Kate Krampton')
    expect(second_row).to have_text('kate.krampton@coventry.gov.uk')
    expect(second_row).to have_text('0') # sign-ins
    expect(second_row).to have_text('Never')

    expect(responsible_body_page.user_rows[2]).to have_text('Amy Adams')
  end
end
