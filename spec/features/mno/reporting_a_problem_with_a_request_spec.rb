require 'rails_helper'

RSpec.describe 'Reporting a problem with an ExtraMobileDataRequest', type: :feature do
  let(:mno_user) { create(:mno_user) }

  context 'signed in as an MNO user' do
    before do
      sign_in_as mno_user
    end

    context 'with 2 existing requests' do
      let(:requests) { create_list(:extra_mobile_data_request, 2, mobile_network: mno_user.mobile_network) }

      before do
        requests
        visit mno_extra_mobile_data_requests_path
      end

      it 'clicking "Report a problem" shows the "Report a problem" form' do
        within("#request-#{requests.first.id}") do
          click_on('Report a problem')
        end

        expect(page).to have_content('Report a problem')
      end

      it 'submitting the form without choosing a problem returns an error' do
        within("#request-#{requests.first.id}") do
          click_on('Report a problem')
        end

        click_on 'Report problem'

        expect(page).to have_http_status(:unprocessable_entity)
      end

      it 'choosing a problem and submitting the form updates the status of the request' do
        within("#request-#{requests.first.id}") do
          click_on('Report a problem')
        end

        choose 'This account is no longer on our network'
        click_on 'Report problem'

        within("#request-#{requests.first.id}") do
          expect(page).to have_content('Not on network')
          expect(page).to have_link('Change problem')
        end
      end
    end
  end
end
