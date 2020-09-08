require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Download user changes CSV' do
  context 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }

    before do
      sign_in_as user
    end

    it 'shows me a Download CSV link' do
      expect(page).to have_link('Download CSV')
    end

    describe 'clicking Download CSV' do
      let!(:user_who_has_seen_privacy_notice_and_can_order_devices) { create(:school_user, :has_seen_privacy_notice, :orders_devices) }
      let!(:user_who_has_seen_privacy_notice_but_cant_order_devices) { create(:school_user, :has_seen_privacy_notice, orders_devices: false) }
      let!(:user_who_has_not_seen_privacy_notice_but_can_order_devices) { create(:school_user, :orders_devices, privacy_notice_seen_at: nil) }

      it 'downloads a CSV file' do
        click_on 'Download CSV'
        expect_download(content_type: 'text/csv')
        expect(page.body).to include(Computacenter::Ledger.headers.join(','))
      end

      it 'includes only users who have seen the privacy notice and can order devices' do
        click_on 'Download CSV'
        expect(page.body).to include(user_who_has_seen_privacy_notice_and_can_order_devices.email_address)
        expect(page.body).not_to include(user_who_has_seen_privacy_notice_but_cant_order_devices.email_address)
        expect(page.body).not_to include(user_who_has_not_seen_privacy_notice_but_can_order_devices.email_address)
      end
    end
  end

  context 'signed in as a non-Computacenter user' do
    let(:user) { create(:local_authority_user) }

    before do
      sign_in_as user
    end

    it 'responds with forbidden' do
      visit computacenter_home_path
      expect(page).to have_http_status(:forbidden)
      visit computacenter_user_ledger_path(format: :csv)
      expect(page).to have_http_status(:forbidden)
    end
  end
end
