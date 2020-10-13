require 'rails_helper'

RSpec.feature 'Reduced allocations due to supply chain delays' do
  include ViewHelper

  let(:responsible_body) { create(:local_authority, :in_devices_pilot) }
  let!(:user) { create(:local_authority_user, responsible_body: responsible_body) }

  before do
    given_i_am_signed_in_as_a_responsible_body_user
  end

  scenario 'I see that allocation have been reduced' do
    given_i_am_signed_in_as_a_responsible_body_user
    when_i_visit_the_reduced_allocations_page
    then_i_see_that_allocations_were_reduced
  end

  def given_i_am_signed_in_as_a_responsible_body_user
    sign_in_as user
  end

  def when_i_visit_the_reduced_allocations_page
    visit responsible_body_devices_reduced_allocations_path
    expect(page).to have_http_status(:ok)
  end

  def then_i_see_that_allocations_were_reduced
    expect(page).to have_text('We reduced device allocations because of delays in our supply chain')
    expect(page).to have_text('Allocations of devices are now based on')
  end
end
