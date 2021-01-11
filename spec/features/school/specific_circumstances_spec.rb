require 'rails_helper'

RSpec.feature 'Accessing the get help for specific circumstances area as a school user', type: :feature do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  context 'when the MNO offer is activated' do
    before do
      school.update!(mno_feature_flag: true)
      sign_in_as user
    end

    scenario 'the user can navigate to the specific circumstances page from the home page' do
      click_on 'Get help for specific circumstances'

      expect(page).to have_css('h1', text: 'Get help for specific circumstances')
      expect(page).to have_http_status(:ok)
    end

    scenario 'the user can navigate to request devices from the specific circumstances page' do
      visit specific_circumstances_school_path(school)

      click_on 'Request devices for specific circumstances'
      expect(page).to have_css('h1', text: 'Request devices for specific circumstances')
    end

    scenario 'the user can navigate to request extra mobile data from the specific circumstances page' do
      visit specific_circumstances_school_path(school)

      click_on 'Request extra mobile data for specific circumstances'
      expect(page).to have_css('h1', text: 'Get internet access')
    end
  end

  context 'when the MNO offer is not activated' do
    before do
      school.update!(mno_feature_flag: false)
      sign_in_as user
    end

    scenario 'the user cannot navigate to the specific circumstances page from the home page' do
      expect(page).not_to have_content('Get help for specific circumstances')
    end
  end
end
