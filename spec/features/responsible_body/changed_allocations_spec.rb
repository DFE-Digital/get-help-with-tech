require 'rails_helper'

RSpec.feature 'Changing allocations', with_feature_flags: { reduced_allocations: 'active' } do
  include ViewHelper

  let(:responsible_body) { create(:local_authority) }
  let!(:user) { create(:local_authority_user, responsible_body: responsible_body) }

  scenario 'I see that allocations are changing' do
    given_i_am_signed_in_as_a_responsible_body_user
    when_i_follow_the_more_about_allocation_changes_link
    then_i_see_that_allocations_changed
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def when_i_follow_the_more_about_allocation_changes_link
    click_on 'More about changes to allocations'
  end

  def then_i_see_that_allocations_changed
    expect(page).to have_http_status(:ok)
    expect(page).to have_text('We’ve changed how we allocate devices')
  end
end
