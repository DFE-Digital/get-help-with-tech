require 'rails_helper'

RSpec.describe 'Deleting users' do
  let(:support_user) { create(:support_user) }
  let(:existing_user) { create(:school_user) }

  it 'support deletes an existing user' do
    given_i_am_signed_in_as_a_support_user
    when_i_visit_an_existing_users_page
    and_i_delete_the_user
    then_user_deletion_is_confirmed
    and_the_user_cannot_sign_into_the_service
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as support_user
  end

  def when_i_visit_an_existing_users_page
    visit support_user_path(existing_user)
  end

  def and_i_delete_the_user
    click_on 'Delete this user' # link to the confirmation page
    click_on 'Yes, delete user' # button on the confirmation page
  end

  def then_user_deletion_is_confirmed
    expect(page).to have_text('You have deleted this user')
  end

  def and_the_user_cannot_sign_into_the_service
    click_on 'Sign out'

    find('.govuk-header__link', text: 'Sign in').click
    fill_in 'Email address', with: existing_user.email_address
    click_on 'Continue'

    expect(page).to have_text('We did not recognise that email address')
  end
end
