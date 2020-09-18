require 'rails_helper'
require 'shared/expect_download'

RSpec.feature 'Download CSV files' do
  let(:user) { create(:computacenter_user) }

  context 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }

    before do
      sign_in_as user
    end

    it 'shows me a Download TechSource users link' do
      expect(page).to have_link('Download TechSource users')
    end

    it 'shows me a Download Chromebook details link' do
      expect(page).to have_link('Download Chromebook details')
    end

    describe 'clicking Download Chromebook details' do
      before do
        create_list(:preorder_information, 4, :needs_chromebooks)
      end

      it 'downloads a CSV file' do
        click_on 'Download Chromebook details'
        expect_download(content_type: 'text/csv')
        expect(page.body).to include(Computacenter::ChromebookDetails::HEADERS.join(','))
      end
    end

    describe 'clicking Download TechSource users' do
      let!(:user_change_1) { create(:user_change, :new_local_authority_user, updated_at_timestamp: Time.zone.now.utc - 2.seconds) }
      let!(:user_change_2) { create(:user_change, :school_user, :changed_telephone, updated_at_timestamp: Time.zone.now.utc - 1.second) }
      let!(:user_change_3) { create(:user_change, :school_user, :school_changed, updated_at_timestamp: Time.zone.now.utc) }

      it 'downloads a CSV file' do
        click_on 'Download TechSource users'
        expect_download(content_type: 'text/csv')
        expect(page.body).to include(Computacenter::Ledger.headers.join(','))
      end

      it 'includes all Computacenter::UserChanges in timestamp order' do
        click_on 'Download TechSource users'
        csv = CSV.parse(page.body, headers: true)
        expect(csv[0]['Email']).to eq(user_change_1.email_address)
        expect(csv[0]['Responsible Body']).to eq(user_change_1.responsible_body)

        expect(csv[1]['Email']).to eq(user_change_2.email_address)
        expect(csv[1]['Telephone']).to eq(user_change_2.telephone)
        expect(csv[1]['Original Telephone']).to eq(user_change_2.original_telephone)

        expect(csv[2]['Email']).to eq(user_change_3.email_address)
        expect(csv[2]['School']).to eq(user_change_3.school)
        expect(csv[2]['Original School']).to eq(user_change_3.original_school)
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
