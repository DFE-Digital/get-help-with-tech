require 'rails_helper'

RSpec.feature 'Submitting eligibility and BT hotspot information', type: :feature do
  let(:user) { create(:local_authority_user) }

  before do
    sign_in_as user
  end

  context 'for the first time' do
    scenario 'takes the user through the form, confirmation and back to the homepage' do
      visit responsible_body_home_path
      expect(page).to have_http_status(:ok)
      expect(page).to have_css('#step-1-status', text: 'Not started yet')

      click_on 'How many young people are eligible?'

      # TODO: rest of the spec will be added here
    end
  end

  context 'after the information has already been submitted' do
    before do
      create(:allocation_request, created_by_user: user, responsible_body: user.responsible_body)
    end

    scenario 'updates the info for the responsible body' do
      visit responsible_body_home_path
      expect(page).to have_css('#step-1-status', text: 'Completed')

      click_on 'How many young people are eligible?'

      # TODO: rest of the spec will be added here
    end
  end
end
