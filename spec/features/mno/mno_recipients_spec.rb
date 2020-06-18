require 'rails_helper'
require 'support/sign_in_as'
require 'shared/expect_download'

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
      expect(page).to have_content('Requests for extra mobile data')
      expect(page).to have_content("#{mno_user.mobile_network.brand} customers")
      expect(page).to have_content(recipient_for_mno.account_holder_name)
      expect(page).not_to have_content(recipient_for_other_mno.account_holder_name)
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
    # NOTE: a function, not a let, so that it re-runs each time
    def rendered_ids
      all('tbody tr').map { |e| e[:id].split('-').last.to_i }
    end
    let(:mno_recipients) do
      Recipient.where(mobile_network_id: mno_user.mobile_network_id)
    end

    before do
      create_list(:recipient, 5, status: 'requested', mobile_network: mno_user.mobile_network)
      sign_in_as mno_user
      click_on 'Your requests'
    end

    scenario 'clicking on a header sorts by that column' do
      click_on 'Account holder'
      expect(rendered_ids).to eq(mno_recipients.order(:account_holder_name).pluck(:id))

      click_on 'Requested'
      expect(rendered_ids).to eq(mno_recipients.order(:created_at).pluck(:id))
    end

    scenario 'clicking on a header twice sorts by that column in reverse order' do
      click_on 'Account holder'
      expect(rendered_ids).to eq(mno_recipients.order(:account_holder_name).pluck(:id))

      click_on 'Account holder'
      expect(rendered_ids).to eq(mno_recipients.order(account_holder_name: :desc).pluck(:id))
    end

    scenario 'updating selected recipients to a status applies that status' do
      all('input[name="mno_recipients_form[recipient_ids][]"]').first(3).each(&:check)
      select('In progress', from: 'Set status of selected to')
      click_on('Update')
      expect(all('.recipient-status').first(3)).to all(have_content('In progress'))
      expect(all('.recipient-status').last(2)).to all(have_no_content('In progress'))
    end

    scenario 'clicking Download as CSV downloads a CSV file' do
      click_on 'Download requests as CSV'
      expect_download(content_type: 'text/csv')
    end
  end
end
