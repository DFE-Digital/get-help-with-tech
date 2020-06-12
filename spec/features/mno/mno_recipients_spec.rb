require 'rails_helper'
require 'support/sign_in_as'

RSpec.feature 'Session behaviour', type: :feature do
  let(:mno_user) { create(:mno_user) }
  let(:other_mno) { create(:mobile_network, brand: 'Other MNO') }
  let(:user_from_other_mno) { create(:mno_user, name: 'Other MNO-User', organisation: 'Other MNO', mobile_network: other_mno) }

  context 'visiting Your requests signed in as an mno user' do
    let!(:recipient_for_mno) { create(:recipient, full_name: 'mno recipient', mobile_network: mno_user.mobile_network) }
    let!(:recipient_for_other_mno) { create(:recipient, full_name: 'other mno recipient', mobile_network: other_mno) }

    before do
      sign_in_as mno_user
      click_on 'Your requests'
    end

    scenario 'shows only requests from my MNO' do
      expect(page).to have_content("Requests for data-cap-raises for #{mno_user.mobile_network.brand} customers")
      expect(page).to have_content(recipient_for_mno.full_name)
      expect(page).not_to have_content(recipient_for_other_mno.full_name)
    end

    scenario 'clicking Select All selects all checkboxes' do
      click_on 'all'

      all('input[name="mno_recipients_form[recipient_ids][]"]').each do |e|
        expect(e.checked?).to eq(true)
      end
    end

    scenario 'clicking Select None de-selects all checkboxes' do
      check('mno_recipients_form[recipient_ids][]')
      click_on 'none'

      all('input[name="mno_recipients_form[recipient_ids][]"]').each do |e|
        expect(e.checked?).to eq(false)
      end
    end
  end
end
