require 'rails_helper'

RSpec.feature 'Request devices in special circumstances' do
  let(:school_user) { create(:school_user, full_name: 'AAA Smith') }

  context 'logged in as a school user' do
    before do
      sign_in_as school_user
    end

    scenario 'Finding out about requesting devices' do
      click_on 'Request devices for specific circumstances'

      expect(page).to have_content('You can request devices at any time for disadvantaged children')
    end
  end
end
