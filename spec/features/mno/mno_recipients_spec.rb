require 'rails_helper'
require 'support/sign_in_as'

RSpec.feature 'MNO Requests view', type: :feature do
  let(:mno_user) { create(:mno_user) }
  let(:other_mno) { create(:mobile_network, brand: 'Other MNO') }
  let(:user_from_other_mno) { create(:mno_user, name: 'Other MNO-User', organisation: 'Other MNO', mobile_network: other_mno) }
  let!(:recipient_for_mno) { create(:recipient, full_name: 'mno recipient', mobile_network: mno_user.mobile_network) }
  let!(:recipient_for_other_mno) { create(:recipient, full_name: 'other mno recipient', mobile_network: other_mno) }

  context 'visiting Your requests signed in as an mno user' do
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

  context 'with several recipients shown' do
    before do
      create_list(:recipient, 5, status: 'requested', mobile_network: mno_user.mobile_network)
      sign_in_as mno_user
      click_on 'Your requests'
    end

    scenario 'updating selected recipients to a status applies that status' do
      all('input[name="mno_recipients_form[recipient_ids][]"]').first(3).each do |e|
        e.check
      end
      select('In progress', from: 'Set selected to')
      click_on('Update')
      all('.recipient-status').first(3).each do |e|
        expect(e).to have_content('In progress')
      end
      all('.recipient-status').last(2).each do |e|
        expect(e).not_to have_content('In progress')
      end

    end
  end
end
