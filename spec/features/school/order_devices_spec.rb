require 'rails_helper'

RSpec.feature 'Order devices (outside lockdown)' do
  let(:school_user) { create(:school_user, full_name: 'AAA Smith') }

  context 'logged in as a school user' do
    before do
      sign_in_as school_user
    end

    scenario 'Finding out about ordering devices' do
      click_on 'Order devices'

      expect(page).to have_content('You cannot order devices yet')
      expect(page).to have_link('request devices for disadvantaged children')
    end
  end
end
