require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'MNO Requests view', type: :feature do
  let(:local_authority_user) { create(:local_authority_user) }
  let(:unapproved_user) { create(:local_authority_user, email_address: 'dubious@example.com', approved_at: nil) }
  let(:mno_user) { create(:mno_user) }
  let(:other_mno) { create(:mobile_network, brand: 'Other MNO') }
  let(:user_from_other_mno) { create(:mno_user, name: 'Other MNO-User', organisation: 'Other MNO', mobile_network: other_mno) }
  let!(:extra_mobile_data_request_for_mno) { create(:extra_mobile_data_request, account_holder_name: 'mno extra_mobile_data_request', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:extra_mobile_data_request_for_other_mno) { create(:extra_mobile_data_request, account_holder_name: 'other mno extra_mobile_data_request', mobile_network: other_mno, created_by_user: local_authority_user) }
  let!(:extra_mobile_data_request_from_unapproved_user) { create(:extra_mobile_data_request, account_holder_name: 'mno extra_mobile_data_request from unapproved user', mobile_network: mno_user.mobile_network, created_by_user: unapproved_user) }

  context 'visiting Your requests signed in as an mno user with extra_mobile_data_offer FeatureFlag active' do
    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
      sign_in_as mno_user
      click_on 'Your requests'
    end

    scenario 'shows only requests from my MNO' do
      expect(page).to have_content('Requests for extra mobile data')
      expect(page).to have_content(mno_user.mobile_network.brand)
      expect(page).to have_content(extra_mobile_data_request_for_mno.account_holder_name)
      expect(page).not_to have_content(extra_mobile_data_request_for_other_mno.account_holder_name)
    end

    scenario 'does not show requests from users who are not approved' do
      expect(page).to have_content(extra_mobile_data_request_for_mno.account_holder_name)
      expect(page).not_to have_content(extra_mobile_data_request_from_unapproved_user.account_holder_name)
    end

    scenario 'clicking Select All selects all checkboxes' do
      click_on 'all'

      all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').each do |e|
        expect(e.checked?).to eq(true)
      end
    end

    scenario 'clicking Select None de-selects all checkboxes' do
      check('mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]')
      click_on 'none'

      all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').each do |e|
        expect(e.checked?).to eq(false)
      end
    end
  end

  context 'with extra_mobile_data_offer FeatureFlag active and several extra_mobile_data_requests shown' do
    # NOTE: a function, not a let, so that it re-runs each time
    def rendered_ids
      all('tbody tr').map { |e| e[:id].split('-').last.to_i }
    end
    let(:mno_extra_mobile_data_requests) do
      ExtraMobileDataRequest.from_approved_users.where(mobile_network_id: mno_user.mobile_network_id)
    end

    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
      create_list(:extra_mobile_data_request, 5, status: 'requested', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user)
      sign_in_as mno_user
      click_on 'Your requests'
    end

    scenario 'clicking on a header sorts by that column' do
      click_on 'Account holder'
      expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(:account_holder_name).pluck(:id))

      click_on 'Requested'
      expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(:created_at).pluck(:id))
    end

    scenario 'clicking on a header twice sorts by that column in reverse order' do
      click_on 'Account holder'
      expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(:account_holder_name).pluck(:id))

      click_on 'Account holder'
      expect(rendered_ids).to eq(mno_extra_mobile_data_requests.order(account_holder_name: :desc).pluck(:id))
    end

    scenario 'updating selected extra_mobile_data_requests to a status applies that status' do
      all('input[name="mno_extra_mobile_data_requests_form[extra_mobile_data_request_ids][]"]').first(3).each(&:check)
      select('In progress', from: 'Set status of selected to')
      click_on('Update')
      expect(all('.extra_mobile_data_request-status').first(3)).to all(have_content('In progress'))
      expect(all('.extra_mobile_data_request-status').last(2)).to all(have_no_content('In progress'))
    end

    scenario 'clicking Download as CSV downloads a CSV file' do
      click_on 'Download requests as CSV'
      expect_download(content_type: 'text/csv')
    end
  end

  context 'with extra_mobile_data_offer FeatureFlag active and multiple pages of extra_mobile_data_requests' do
    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
      create_list(:extra_mobile_data_request, 25, status: 'requested', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user)
      sign_in_as mno_user
      click_on 'Your requests'
    end

    it 'shows pagination' do
      expect(page).to have_link('Next')
    end

    it 'shows all/none checkbox when on subsequent pages' do
      click_on('Next')
      expect { page.find('input#all-rows') }.not_to raise_error
    end
  end

  context 'when the extra_mobile_data_offer FeatureFlag is active and the requests are complete or cancelled' do
    let!(:complete_request) do
      create(:extra_mobile_data_request, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user, status: 'complete')
    end
    let!(:cancelled_request) do
      create(:extra_mobile_data_request, mobile_network: mno_user.mobile_network, created_by_user: local_authority_user, status: 'cancelled')
    end

    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
      extra_mobile_data_request_for_mno.update(status: 'complete')
      sign_in_as mno_user
      click_on 'Your requests'
    end

    it 'shows the status' do
      within("#request-#{complete_request.id}") do
        expect(page).to have_text('Complete')
      end
      within("#request-#{cancelled_request.id}") do
        expect(page).to have_text('Cancelled')
      end
    end

    it 'does not show a link to Report a problem' do
      expect(page).not_to have_link('Report a problem')
    end
  end

  context 'visiting Your requests signed in as an mno user with extra_mobile_data_offer FeatureFlag inactive' do
    before do
      FeatureFlag.deactivate(:extra_mobile_data_offer)
      sign_in_as mno_user
    end

    it 'returns a 404' do
      visit mno_extra_mobile_data_requests_path
      expect(page).to have_http_status(:not_found)
      expect(page).to have_text('Page not found')
    end
  end
end
