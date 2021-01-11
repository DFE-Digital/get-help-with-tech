require 'rails_helper'

RSpec.feature 'Request devices in special circumstances' do
  let(:school_user) { create(:school_user, full_name: 'AAA Smith') }
  let(:school) { school_user.school }

  context 'logged in as a school user' do
    before do
      sign_in_as school_user
    end

    scenario 'Finding out about requesting devices' do
      click_on 'Request devices for specific circumstances'

      expect(page).to have_content('You can request devices at any time for disadvantaged children')
    end

    context 'when the MNO offer is activated' do
      before do
        school.update!(mno_feature_flag: true)
      end

      scenario 'includes the intermediary specific circumstances page in breadcrumbs' do
        visit request_devices_school_path(school)
        expect(page).to have_link('Get help for specific circumstances')
      end
    end

    context 'when the MNO offer is not activated' do
      before do
        school.update!(mno_feature_flag: false)
      end

      scenario 'does not include the intermediary specific circumstances page in breadcrumbs' do
        visit request_devices_school_path(school)
        expect(page).not_to have_link('Get help for specific circumstances')
      end
    end
  end
end
