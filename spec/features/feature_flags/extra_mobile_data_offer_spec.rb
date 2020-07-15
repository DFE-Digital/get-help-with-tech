require 'rails_helper'

describe 'extra_mobile_data_offer FeatureFlag' do
  let(:mno_user) { create(:mno_user) }
  let(:local_authority_user) { create(:local_authority_user, :approved) }
  let(:extra_mobile_data_request) { create(:extra_mobile_data_request, created_by_user: local_authority_user, mobile_network: mno_user.mobile_network) }

  context 'with the feature active' do
    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
    end

    describe 'signing in as an MNO user' do
      before do
        sign_in_as mno_user
      end

      it 'redirects to the Your requests page' do
        expect(page).to have_current_path(mno_extra_mobile_data_requests_path)
      end

      it 'shows the correct page when going direct to the mno_extra_mobile_data_requests page' do
        visit mno_extra_mobile_data_requests_path
        expect(page).to have_http_status(:ok)
        expect(page).to have_text('Requests for extra mobile data')
      end

      it 'shows the correct page when going direct to the Report a problem page' do
        visit mno_extra_mobile_data_request_report_problem_path(extra_mobile_data_request)
        expect(page).to have_http_status(:ok)
        expect(page).to have_text('Report a problem')
      end
    end

    describe 'signed in as an RB user' do
      before do
        sign_in_as local_authority_user
      end

      it 'shows the option to request extra mobile data' do
        expect(page).to have_link('Request extra data for mobile devices')
      end

      it 'allows the user to request extra mobile data' do
        click_on 'Request extra data for mobile devices'
        expect(page).to have_link('Request data for someone')

        click_on 'Request data for someone'
        expect(page).to have_text('Who needs the extra mobile data?')
      end
    end
  end

  context 'with the feature inactive' do
    before do
      FeatureFlag.deactivate(:extra_mobile_data_offer)
    end

    describe 'signing in as an MNO user' do
      before do
        sign_in_as mno_user
      end

      it 'redirects to the guidance page' do
        expect(page).to have_current_path(guidance_page_path)
      end

      it 'shows a 404 when going direct to the mno_extra_mobile_data_requests page' do
        visit mno_extra_mobile_data_requests_path
        expect(page).to have_http_status(:not_found)
        expect(page).to have_text('Page not found')
      end

      it 'shows a 404 when going direct to the Report a problem page' do
        visit mno_extra_mobile_data_request_report_problem_path(extra_mobile_data_request)
        expect(page).to have_http_status(:not_found)
        expect(page).to have_text('Page not found')
      end
    end

    describe 'signed in as an RB user' do
      before do
        sign_in_as local_authority_user
      end

      it 'does not show the option to request extra mobile data' do
        expect(page).not_to have_link('Request extra data for mobile devices')
      end

      it 'does not allow the user to request extra mobile data' do
        visit(new_responsible_body_extra_mobile_data_request_path)
        expect(page).to have_http_status(:not_found)
        expect(page).not_to have_text('Who needs the extra mobile data?')
      end
    end
  end
end
