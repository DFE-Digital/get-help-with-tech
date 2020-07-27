require 'rails_helper'

RSpec.feature 'Accessing the extra mobile data requests area as a responsible body user', type: :feature do
  let(:rb_user) { create(:local_authority_user) }

  before do
    sign_in_as rb_user
  end

  scenario 'the user can access the request form from the responsible body home page' do
    click_on 'Request extra data for mobile devices'

    expect(page).to have_css('h1', text: 'Request extra mobile data')
    expect(page).to have_http_status(:ok)
    expect(page).to have_link('Request data for someone')
  end

  context 'when the user has already submitted requests' do
    before do
      @requests = create_list(:extra_mobile_data_request, 5, status: 'requested', created_by_user: rb_user)
    end

    scenario 'the user can see their previous requests' do
      visit responsible_body_extra_mobile_data_requests_path

      expect(page).to have_css('h2', text: 'Your requests')

      @requests.each do |request|
        expect(page).to have_content(request.device_phone_number)
        expect(page).to have_content(request.account_holder_name)
      end
    end
  end
end
