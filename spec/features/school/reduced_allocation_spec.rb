require 'rails_helper'

RSpec.feature 'Reduced allocation due to supply chain delays', with_feature_flags: { reduced_allocations: 'active' } do
  include ViewHelper

  let(:school) { create(:school, :with_std_device_allocation) }

  scenario 'when a school has an allocation' do
    given_i_am_signed_in_as_a_school_user
    when_i_follow_the_more_about_your_reduced_allocation_link
    then_i_see_my_reduced_allocation
  end

  context 'when a school has no allocation' do
    let(:school) { create(:school) }

    scenario 'I see that my allocation was removed' do
      given_i_am_signed_in_as_a_school_user
      when_i_follow_the_more_about_this_change_link
      then_i_see_that_my_allocation_was_removed
    end
  end

  def given_i_am_signed_in_as_a_school_user
    @school_user = create(:school_user,
                          school: school,
                          full_name: 'AAA Smith',
                          orders_devices: true,
                          techsource_account_confirmed_at: 1.second.ago)

    sign_in_as @school_user
  end

  def when_i_follow_the_more_about_this_change_link
    click_on 'More about this change to your allocation'
  end

  def when_i_follow_the_more_about_your_reduced_allocation_link
    click_on 'More about your reduced allocation'
  end

  def then_i_see_my_reduced_allocation
    expect(page).to have_http_status(:ok)
    expect(page).to have_text("Your new allocation of #{school.std_device_allocation.allocation}")
  end

  def then_i_see_that_my_allocation_was_removed
    expect(page).to have_http_status(:ok)
    expect(page).to have_text('We removed your allocation because of delays in our supply chain')
  end
end
