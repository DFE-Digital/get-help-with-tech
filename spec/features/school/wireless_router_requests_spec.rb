require 'rails_helper'

RSpec.feature 'Accessing the 4G wireless routers requests area as a school user', type: :feature do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  before do
    school.update!(mno_feature_flag: true)
    sign_in_as user
  end

  context 'when the MNO offer is activated' do
    scenario 'the user can navigate to the request 4G wireless routers page from the home page' do
      click_on 'Get internet access'
      click_on 'Request 4G wireless routers'

      expect(page).to have_css('h1', text: 'How to request 4G wireless routers')
      expect(page).to have_http_status(:ok)
    end
  end
end
