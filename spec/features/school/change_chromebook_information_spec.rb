require 'rails_helper'

RSpec.feature 'Change school Chromebook information' do
  let(:school) { create(:school, :la_maintained) }
  let(:school_user) { create(:school_user, full_name: 'AAA Smith', school:) }

  before do
    school.update!(who_will_order_devices: 'school',
                   will_need_chromebooks: 'yes',
                   raw_laptop_allocation: 63,
                   over_order_reclaimed_laptops: -63,
                   raw_laptops_ordered: 0)
  end

  context 'logged in as a school user' do
    before do
      sign_in_as school_user
    end

    context "when the user's school is of type LaFundedPlace" do
      let(:school) { create(:iss_provision) }

      it "dont display the school's details" do
        expect(page).not_to have_content('Check your organisation’s details')

        visit details_school_path(school)

        expect(page).to have_content('Forbidden')
        expect(page).not_to have_content('Set your Chromebook preferences')
      end
    end
  end
end
