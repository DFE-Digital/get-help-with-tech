require 'rails_helper'

RSpec.feature 'RB ExtraMobileDataRequests view', type: :feature do
  let(:rb_user) { create(:local_authority_user) }

  describe 'logged in as an RB user' do
    before do
      sign_in_as rb_user
    end

    scenario 'visiting the index works' do
      visit responsible_body_extra_mobile_data_requests_path

      expect(page).to have_css('h1', text: 'Request extra mobile data')
      expect(page).to have_http_status(:ok)
    end

    context 'when the user has submitted requests' do
      let(:requests) { create_list(:extra_mobile_data_request, 5, status: 'requested', created_by_user: rb_user) }

      before do
        requests
      end

      scenario 'the index page shows the users requests' do
        visit responsible_body_extra_mobile_data_requests_path

        expect(page).to have_css('h2', text: 'Your requests')
      end

      scenario 'the index page shows those requests' do
        visit responsible_body_extra_mobile_data_requests_path

        requests.each do |request|
          expect(page).to have_content(request.device_phone_number)
          expect(page).to have_content(request.account_holder_name)
        end
      end
    end

    scenario 'the index page shows a button for requesting more data' do
      visit responsible_body_extra_mobile_data_requests_path

      expect(page).to have_link('Request data for someone')
    end
  end
end
