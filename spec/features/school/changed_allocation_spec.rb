require 'rails_helper'

RSpec.feature 'Changing allocation', with_feature_flags: { reduced_allocations: 'active' } do
  include ViewHelper

  let(:school) { create(:school, :with_std_device_allocation) }

  scenario 'when a school has an allocation' do
    given_i_am_signed_in_as_a_school_user
    when_i_follow_the_more_about_allocation_changes_link
    then_i_see_my_reduced_allocation
  end

  def given_i_am_signed_in_as_a_school_user
    @school_user = create(:school_user,
                          school: school,
                          full_name: 'AAA Smith',
                          orders_devices: true,
                          techsource_account_confirmed_at: 1.second.ago)

    sign_in_as @school_user
  end

  def when_i_follow_the_more_about_allocation_changes_link
    click_on 'More about changes to allocations'
  end

  def then_i_see_my_reduced_allocation
    expect(page).to have_http_status(:ok)
    expect(page).to have_text('We’ve changed how we allocate devices')
  end
end
