require 'rails_helper'

RSpec.feature 'Reduced allocations due to supply chain delays' do
  include ViewHelper

  let(:responsible_body) { create(:local_authority, :in_devices_pilot) }
  let!(:user) { create(:local_authority_user, responsible_body: responsible_body) }

  around do |example|
    FeatureFlag.activate(:reduced_allocations)
    given_i_am_signed_in_as_a_responsible_body_user
    example.run
    FeatureFlag.deactivate(:reduced_allocations)
  end

  scenario 'I see that allocations have been reduced' do
    given_i_am_signed_in_as_a_responsible_body_user
    when_i_follow_the_more_about_reduced_allocations_link
    then_i_see_that_allocations_were_reduced
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def when_i_follow_the_more_about_reduced_allocations_link
    click_on 'More about changes to allocations'
  end

  def then_i_see_that_allocations_were_reduced
    expect(page).to have_http_status(:ok)
    expect(page).to have_text('We reduced device allocations because of delays in our supply chain')
    expect(page).to have_text('Allocations of devices are now based on')
  end
end
